#!/usr/bin/env python3
"""Read OpenWrt WAN counters over authenticated, certificate-pinned ubus HTTPS."""
import hashlib
import http.client
import argparse
import json
import os
from pathlib import Path
import ssl
import sys
import time
from urllib.parse import urlsplit


def collect(credential_path, certificate_path, cache_path):
    config = json.loads(credential_path.read_text())
    pem = certificate_path.read_text()
    context = ssl.create_default_context(cadata=pem)
    # The router's certificate uses the name OpenWrt. Trust its exact certificate
    # (copied over authenticated SSH) instead of requiring a LAN-IP hostname.
    context.check_hostname = False
    expected_cert = ssl.PEM_cert_to_DER_cert(pem)
    expected_fingerprint = hashlib.sha256(expected_cert).digest()
    url = urlsplit(config['url'])
    if url.scheme != 'https':
        raise ValueError('HTTPS is required')

    def call(session, obj, method, args):
        body = json.dumps({'jsonrpc': '2.0', 'id': 1, 'method': 'call',
                           'params': [session, obj, method, args]}).encode()
        connection = http.client.HTTPSConnection(url.hostname, url.port or 443,
                                                 context=context, timeout=5)
        try:
            connection.connect()
            actual_cert = connection.sock.getpeercert(binary_form=True)
            if hashlib.sha256(actual_cert).digest() != expected_fingerprint:
                raise ValueError('Router certificate has changed')
            connection.request('POST', url.path or '/ubus', body,
                               {'Content-Type': 'application/json'})
            response = connection.getresponse()
            if response.status != 200:
                raise ValueError('HTTP request failed')
            result = json.load(response).get('result', [])
        finally:
            connection.close()
        if not result or result[0] != 0 or len(result) < 2:
            raise ValueError('ubus request failed')
        return result[1]

    login = call('0' * 32, 'session', 'login',
                 {'username': config['username'], 'password': config['password']})
    session = login['ubus_rpc_session']
    wan = call(session, 'network.interface.' + config['interface'], 'status', {})
    if not wan.get('up') or not wan.get('l3_device'):
        return {'status': 'unavailable'}
    device = wan['l3_device']
    stats = call(session, 'network.device', 'status', {'name': device})['statistics']
    now = time.monotonic()
    sample = {'time': now, 'device': device, 'uptime': wan['uptime'],
              'rx_bytes': int(stats['rx_bytes']), 'tx_bytes': int(stats['tx_bytes'])}
    output = {'status': 'online', 'device': device, 'sample_time': time.time(),
              'download_bytes': sample['rx_bytes'], 'upload_bytes': sample['tx_bytes'],
              'download_mbps': None, 'upload_mbps': None}
    try:
        previous = json.loads(cache_path.read_text())
        elapsed = now - previous['time']
        valid = (0 < elapsed < 120 and previous['device'] == device
                 and sample['uptime'] >= previous['uptime']
                 and sample['rx_bytes'] >= previous['rx_bytes']
                 and sample['tx_bytes'] >= previous['tx_bytes'])
        if valid:
            for label, key in [('download', 'rx_bytes'), ('upload', 'tx_bytes')]:
                output[label + '_mbps'] = round(
                    (sample[key] - previous[key]) * 8 / elapsed / 1_000_000, 4)
    except (OSError, ValueError, KeyError, TypeError):
        pass
    os.umask(0o077)
    temporary = cache_path.with_suffix('.tmp')
    temporary.write_text(json.dumps(sample))
    temporary.replace(cache_path)
    return output


if __name__ == '__main__':
    directory = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--credentials', type=Path, default=directory / 'openwrt-monitor-credentials.json')
    parser.add_argument('--certificate', type=Path, default=directory / 'openwrt-router.pem')
    parser.add_argument('--cache', type=Path, default=Path('/tmp/ha_openwrt_wan_traffic.json'))
    args = parser.parse_args()
    try:
        print(json.dumps(collect(args.credentials, args.certificate, args.cache)))
    except Exception:
        # Do not leak credentials, session IDs, or raw HTTP responses to HA logs.
        print(json.dumps({'status': 'unavailable'}))
