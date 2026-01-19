{
  config,
  ...
}:
let
  baseName = "home.lolicon.cyou";
in
{
  services.nginx = {
    enable = true;
    defaultSSLListenPort = 21443;
    virtualHosts = {
      "rin.${baseName}" = {
        onlySSL = true;
        sslCertificate = config.age.secrets.loli-cer.path;
        sslCertificateKey = config.age.secrets.loli-priv.path;

        locations = {
          "/" = {
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
      };
    };
  };
}
