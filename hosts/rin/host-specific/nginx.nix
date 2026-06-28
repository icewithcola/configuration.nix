{
  config,
  ...
}:
let
  baseName = "home.lolicon.cyou";
in
{
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
          alias = "/var/lib/qBittorrent/qBittorrent/downloads/";
          extraConfig = ''
            autoindex on;
            charset utf-8;

            expires -1;
            add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0";

            sendfile on;
            tcp_nopush on;
            aio on;
            directio 512;
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
    };
  };
}
