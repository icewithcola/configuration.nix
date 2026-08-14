{
  config,
  pkgs,
  ...
}:
let
  baseName = "home.lolicon.cyou";
in
{
  # nginx binds to the Tailscale IP (100.112.3.53), so it must wait for
  # tailscaled to bring up the tailscale0 interface before starting.
  # tailscaled.service alone is not enough — the interface may not have an IP yet.
  systemd.services.tailscale-online = {
    description = "Wait for Tailscale interface to be online";
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.iproute2 ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for i in $(seq 1 120); do
        if ip -4 addr show tailscale0 2>/dev/null | grep -q 'inet '; then
          echo "tailscale0 has an IPv4 address"
          exit 0
        fi
        sleep 1
      done
      echo "Timed out waiting for tailscale0 IPv4 address" >&2
      exit 1
    '';
  };

  systemd.services.nginx = {
    after = [ "tailscale-online.service" ];
    wants = [ "tailscale-online.service" ];
  };
  users.users.nginx.extraGroups = [ "qbittorrent" ];

  services.nginx = {
    enable = true;
    defaultSSLListenPort = 21443;

    # Optimize
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    # Virtual hosts
    virtualHosts = {
      "_" = {
        default = true;
        sslCertificate = config.age.secrets.loli-cer.path;
        sslCertificateKey = config.age.secrets.loli-priv.path;

        locations."/".return = 444;
      };

      # `forceSSL` redirects to the default HTTPS port, which would send
      # clients to 443.  Keep these redirects explicit for the non-standard
      # listeners instead.
      "http-to-https-21443" = {
        serverAliases = [
          "rin.${baseName}"
          "rin-cm.${baseName}"
          "store.${baseName}"
          "store-cm.${baseName}"
        ];
        locations."/".return = "301 https://$host:21443$request_uri";
      };

      "http-to-https-34512" = {
        serverAliases = [ "vnc-int.${baseName}" ];
        locations."/".return = "301 https://$host:34512$request_uri";
      };

      "immich" = {
        onlySSL = true;
        sslCertificate = config.age.secrets.loli-cer.path;
        sslCertificateKey = config.age.secrets.loli-priv.path;
        serverAliases = [
          "rin.${baseName}"
          "rin-cm.${baseName}"
        ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:2283/";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            client_max_body_size 2G;

            error_page 497 https://$host:$server_port$request_uri;
          '';
        };
      };

      "store" = {
        onlySSL = true;
        serverAliases = [
          "store.${baseName}"
          "store-cm.${baseName}"
        ];
        sslCertificate = config.age.secrets.loli-cer.path;
        sslCertificateKey = config.age.secrets.loli-priv.path;
        locations."/" = {
          proxyPass = "http://127.0.0.1:18080/";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_read_timeout 3600s;
          '';
        };
      };

      "kasmVNC" = {
        onlySSL = true;
        serverAliases = [
          "vnc-int.${baseName}"
        ];
        sslCertificate = config.age.secrets.loli-cer.path;
        sslCertificateKey = config.age.secrets.loli-priv.path;
        listen = [
          {
            addr = "192.168.114.167";
            port = 34512;
            ssl = true;
          }
        ];
        locations."/" = {
          proxyPass = "https://192.168.23.132:8444/";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_ssl_verify off;

            client_max_body_size 2G;

            error_page 497 https://$host:$server_port$request_uri;
          '';
        };
      };

      "telegram" = {
        onlySSL = true;
        serverAliases = [
          "tg.${baseName}"
        ];
        sslCertificate = config.age.secrets.loli-cer.path;
        sslCertificateKey = config.age.secrets.loli-priv.path;
        listen = [
          {
            addr = "100.112.3.53";
            port = 443;
            ssl = true;
          }
        ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:37514/";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_ssl_verify off;

            client_max_body_size 2G;

            error_page 497 https://$host:$server_port$request_uri;
          '';
        };
      };
    };
  };
}
