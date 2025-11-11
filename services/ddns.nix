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

  config.systemd =
    let
      cfg = config.kagura.ddns;
      domain = cfg.host + cfg.suffix;
    in
    lib.mkIf cfg.enable {
      services."kagura-ddns" = {
        script = ''
          set -eu

          ZONE=$(cat ${cfg.secretFile} | ${lib.getExe pkgs.jq} -r .ZONE)
          RECORD_ID=$(cat ${cfg.secretFile} | ${lib.getExe pkgs.jq} -r .RECORD_ID)
          API_KEY=$(cat ${cfg.secretFile} | ${lib.getExe pkgs.jq} -r .API_KEY)

          myip=$(${lib.getExe' pkgs.iproute2 "ip"} -6 -j addr show dev ${cfg.interface} scope global primary -tentative up | ${lib.getExe pkgs.jq} -r '(.[0] // empty).addr_info | sort_by(.prefixlen) | sort_by(.local) | map(.local // empty)[0] // empty')
          ${lib.getExe pkgs.curl} https://api.cloudflare.com/client/v4/zones/''${ZONE}/dns_records/''${RECORD_ID} \
            -X PUT \
            -H "Authorization: Bearer ''${API_KEY}" \
            -H "Content-Type: application/json" \
            -d "{
              \"type\": \"AAAA\",
              \"ttl\": 120,
              \"name\": \"${domain}\",
              \"content\": \"''${myip}\",
              \"proxied\": false
            }"
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };

      timers."kagura-ddns" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "5min";
          OnUnitActiveSec = "10min";
          Unit = "kagura-ddns.service";
        };
      };
    };
}
