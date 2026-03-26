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
        locations."/".return = 444;
      };

      "rin.${baseName}" = {
        onlySSL = true;
        sslCertificate = config.age.secrets.loli-cer.path;
        sslCertificateKey = config.age.secrets.loli-priv.path;
        serverAliases = [
          "rin.${baseName}"
          "rin-cm.${baseName}"
          "immich-server-from-overseas2.lolicon.cyou"
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
          '';
        };
      };

      "store.${baseName}" = {
        onlySSL = true;
        sslCertificate = config.age.secrets.loli-cer.path;
        sslCertificateKey = config.age.secrets.loli-priv.path;
        serverAliases = [
          "rin.${baseName}"
          "rin-cm.${baseName}"
        ];
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
    };
  };
}
