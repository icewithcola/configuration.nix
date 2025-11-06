{ lib, config, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.kagura.frp = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable frp, client";
    };

    remoteServer = mkOption {
      type = types.str;
      example = "server.your.domain";
      description = "The remote server, domain or ip";
    };

    port = mkOption {
      type = types.int;
      example = 11451;
      description = "The port of the remote server";
    };
  };

  services.frp =
    let
      cfg = config.kagura.frp;
    in
    lib.mkIf cfg.enable {
      enable = true;
      role = "client";
      settings = {
        serverAddr = cfg.remoteServer;
        serverPort = cfg.port;

        auth.tokenSource = {
          type = "file";
          file = config.age.secrets.frp-token.file;
        };

        proxies = [
          {
            name = "web";
            type = "http";
            localIP = "127.0.0.1";
            localPort = 45323;
            customDomains = [ "al.lolicon.cyou" ];
          }
          {
            name = "ssh";
            type = "tcp";
            localIP = "127.0.0.1";
            localPort = 22;
            remotePort = 30072;
          }
        ];
      };
    };
}
