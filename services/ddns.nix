{ pkgs, lib, config, ...}:
let
  inherit (lib) mkOption types;
  cfg = config.kagura.ddns;
in
{
  options.kagura.ddns = mkOption {
    default = {};
    description = "DDNS configurations";
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable this ddns instance";
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

        recordId = mkOption {
          type = types.str;
          default = "";
          description = "The record ID from Cloudflare";
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
    }));
  };

  config.systemd =
    let
      enabledInstances = lib.filterAttrs (n: v: v.enable) cfg;
    in
    {
      services = lib.mapAttrs' (name: instance: let
          domain = instance.host + instance.suffix;
        in
        lib.nameValuePair "kagura-ddns-${name}" {
          script = ''
            set -eu

            ZONE=$(cat ${instance.secretFile} | ${lib.getExe pkgs.jq} -r .ZONE)
            RECORD_ID="${instance.recordId}"
            API_KEY=$(cat ${instance.secretFile} | ${lib.getExe pkgs.jq} -r .API_KEY)

            myip=$(${lib.getExe' pkgs.iproute2 "ip"} -6 -j addr show dev ${instance.interface} scope global primary -tentative up | ${lib.getExe pkgs.jq} -r '(.[0] // empty).addr_info | sort_by(.prefixlen) | sort_by(.local) | map(.local // empty)[0] // empty')
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
        }
      ) enabledInstances;

      timers = lib.mapAttrs' (name: instance: lib.nameValuePair "kagura-ddns-${name}" {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "5min";
            OnUnitActiveSec = "10min";
            Unit = "kagura-ddns-${name}.service";
          };
        }
      ) enabledInstances;
    };
}