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
        useACMEHost = baseName;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:2283";
          };
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "me@lolicon.cyou";
    certs."${baseName}" = {
      domain = baseName;
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets."cloudflare-token".path;
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];
}
