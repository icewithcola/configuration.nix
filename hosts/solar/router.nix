{
  config,
  lib,
  ...
}:
let
  upstream = "enp1s0";
  downstream = "enp2s0";
  bridge = "br0";
  thisIP = "192.168.114.1";
  thisIPv6 = "fc12:1145::1";
  predictableMac = "1A:2B:3C:4D:14:51";
in
{
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;

    "net.ipv6.conf.all.accept_ra" = 2;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;
  };

  networking = {
    hostName = "solar";
    useDHCP = false;
    defaultGateway.interface = upstream;
    bridges = {
      ${bridge} = {
        interfaces = [
          downstream
        ];
      };
    };

    interfaces = {
      ${upstream}.useDHCP = true;
      ${downstream}.useDHCP = false;

      ${bridge} = {
        useDHCP = false;
        macAddress = predictableMac;
        ipv4.addresses = [
          {
            address = thisIP;
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = thisIPv6;
            prefixLength = 64;
          }
        ];
      };
    };

    nftables = {
      enable = true;
      preCheckRuleset = "sed 's/.*devices.*/devices = { lo }/g' -i ruleset.conf";
      ruleset = ''
                table inet filter {
                  # flow offloading
                  flowtable f {
                    hook ingress priority 0;
                    devices = { ${upstream}, ${bridge} };
                  }

                  chain output {
                    type filter hook output priority 100; policy accept;
                  }

                  chain input {
                    type filter hook input priority filter; policy accept;

                    # Allow trusted networks to access the router
                    iifname { "${bridge}", } counter accept

                    # Allow returning traffic from WAN and drop everthing else
                    iifname "${upstream}" ct state { established, related } counter accept

                    # Allow icmpv6
        		        iifname "${upstream}" ip6 nexthdr icmpv6 icmpv6 type { echo-request, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } counter accept

                    iifname "${upstream}" drop
                  }

                  chain forward {
                    type filter hook forward priority filter; policy drop;

                    # enable flow offloading for better throughput
                    ip protocol { tcp, udp } flow offload @f

                    # Allow trusted network WAN access
                    iifname "${bridge}" oifname "${upstream}" counter accept comment "Allow trusted LAN to WAN"

                    # Allow established WAN to return
                    iifname "${upstream}" oifname "${bridge}" ct state established,related counter accept comment "Allow established back to LANs"
                  }
                }

                table ip nat {
                  chain prerouting {
                    type nat hook prerouting priority filter; policy accept;
                  }

                  # Setup NAT masquerading on the WAN interface
                  chain postrouting {
                    type nat hook postrouting priority filter; policy accept;
                    oifname "${upstream}" masquerade
                  }
                }
      '';
    };

    nat = {
      enable = true;
      externalInterface = upstream;
      internalInterfaces = [ bridge ];
      internalIPs = [ "${thisIP}/24" ];
      internalIPv6s = [ "${thisIPv6}/64" ];
    };

    firewall.enable = false;
  };

  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings = {
      domain-needed = true;
      bogus-priv = true;
      no-resolv = true;

      cache-size = 1000;

      interface = bridge;
      dhcp-host = "${predictableMac},${thisIP}";
      dhcp-range = [
        "192.168.114.25,192.168.114.254,24h"
        "::1,constructor:${bridge},ra-names,ra-stateless"
      ];

      #IPV6
      enable-ra = true;

      local = "/lan/";
      domain = "lan";

      # DNS
      no-hosts = true;
      expand-hosts = true;
      server = [
        # upstream DNS servers
        "223.5.5.5"
        "8.8.8.8"
        "1.1.1.1"
      ];
      address = "/solar.lan/${thisIP}"; # Static dns entry
    };
  };
}
