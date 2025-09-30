{
  lib,
  config,
  pkgs,

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

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "me@lolicon.cyou";

  security.acme.certs.baseName = {
    domain = baseName;
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets."cloudflare-token".path;
  };

  users.users.nginx.extraGroups = [ "acme" ];
}
