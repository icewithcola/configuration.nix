{
  config,
  ...
}:
let
  baseName = "lolicon.cyou";
in
{
  services.nginx = {
    enable = true;
    defaultSSLListenPort = 21443;
    virtualHosts = {
      "rin.home.${baseName}" = {
        onlySSL = true;
        sslCertificate = config.age.secrets.loli-cer.path;
        sslCertificateKey = config.age.secrets.loli-priv.path;

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:2283";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
