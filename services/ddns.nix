{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.kagura.ddns = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable ddns";
    };

    host = mkOption {
      type = types.str;
      default = config.networking.hostName;
      description = "The hostname of the machine";
    };

    suffix = mkOption {
      type = types.str;
      default = ".home.lolicon.cyou";
      description = "The suffix of the hostname";
    };

    secretFile = mkOption {
      type = types.path;
      description = "The path to the secret file, contains ZONE, RECORD_ID, API_KEY";
    };

    interface = mkOption {
      type = types.str;
      default = "eth0";
      description = "The interface to use";
    };
  };

  systemd =
    let
      domain = host + config.kagura.ddns.suffix;
      interface = config.kagura.ddns.interface;
    in
    lib.mkIf config.kagura.ddns.enable {
      services."kagura-ddns" = {
        script = ''
          set -eu
          
          ZONE=$(cat ${secretFile} | ${pkgs.jq} .ZONE)
          RECORD_ID=$(cat ${secretFile} | ${pkgs.jq} .RECORD_ID)
          API_KEY=$(cat ${secretFile} | ${pkgs.jq} .API_KEY)

          myip=$(${lib.getExe' pkgs.iproute2 "ip"} addr show ${interface} | grep "inet6 2" | cut -f 6 -d ' ' | cut -f 1 -d '/')
          ${lib.getExe pkgs.curl} https://api.cloudflare.com/client/v4/zones/$\{ZONE\}/dns_records/$\{RECORD_ID\} \
            -X PUT \
            -H "Authorization: Bearer $\{API_KEY\}" \
            -H "Content-Type: application/json" 
            -d "{
              \"type\": \"AAAA\",
              \"ttl\": 120,
              \"name\": \"$\{domain\}\",
              \"content\": \"$\{myip\}\",
              \"proxied\": false,
            }"
        '';
        serviceConfig = {
          Type = "oneshot";
        };
      };

      systemd.timers."kagura-ddns" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "5min";
          OnUnitActiveSec = "10min";
          Unit = "kagura-ddns.service";
        };
      };
    };
}
