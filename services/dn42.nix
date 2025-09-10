# https://github.com/AsterisMono/flake/blob/main/nixosModules/services/dn42.nix
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.kagura.dn42;
  getIfName = asn: "dn42-${asn}";
  getPort = asn: lib.strings.toInt (lib.removePrefix "42424" (builtins.toString asn));
  getLocalAddr =
    asn: "fd11:4514:1919:810:${lib.removePrefix "424242" (builtins.toString asn)}::1/128";
  generateNetworkdConfig =
    asn: peers:
    let
      networkdEntry = "peer-${asn}";
      ifname = getIfName asn;
    in
    {
      netdevs."${lib.toLower networkdEntry}" = {
        netdevConfig = {
          Name = ifname;
          Kind = "wireguard";
        };
        wireguardConfig = {
          ListenPort = getPort asn;
          PrivateKeyFile = cfg.wireguard.PrivateKey;
        };
        wireguardPeers = lib.lists.forEach peers (peer: [
          {
            PublicKey = peer.wireguard.PublicKey;
            Endpoint = "${peer.wireguard.EndPoint.HostName}:${peer.wireguard.EndPoint.Port}";
            AllowedIPs = [
              "fd00::/8"
              "fe80::/64"
              "${peer.wireguard.EndPoint.MyIP}"
              "${peer.wireguard.EndPoint.PeerIP}"
            ];
            RouteTable = "off";
          }
        ]);
      };
      networks."${lib.toLower networkdEntry}" = {
        matchConfig = {
          Name = ifname;
        };
        networkConfig = {
          Description = "Wireguard tunnel to DN42 peer AS${asn}";
          DHCP = "no";
          IPv6AcceptRA = false;
          KeepConfiguration = "yes";
        };
        linkConfig = {
          RequiredForOnline = "no";
        };
        address = [
          getLocalAddr
          asn
        ];
      };
    };
  roaUrl = "https://dn42.burble.com/roa/dn42_roa_bird2_6.conf";
in
{
  config = lib.mkIf (cfg.enable && cfg.peers != { }) {
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.default.forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv4.conf.default.rp_filter" = 0;
      "net.ipv4.conf.all.rp_filter" = 0;
    };
    systemd.network =
      let
        dummy = "dn42-dummy";
        merge = lib.foldl (a: b: lib.recursiveUpdate a b) { };
      in
      lib.recursiveUpdate
        (lib.zipAttrsWith (_: merge) (lib.mapAttrsToList generateNetworkdConfig cfg.peers))
        {
          enable = true;
          wait-online.enable = !config.networking.networkmanager.enable;

          netdevs."${dummy}" = {
            netdevConfig = {
              Name = dummy;
              Kind = "dummy";
            };
          };
          networks."dn42" = {
            matchConfig = {
              Name = dummy;
            };
            networkConfig = {
              Address = [ cfg.routerIp ];
            };
          };
        };

    services.bird =
      let
        initialRoa = ../assets/dn42/dn42_roa_bird2_6.conf;
      in
      {
        enable = true;
        package = pkgs.bird2;
        config = ''
          ################################################
          #               Variable header                #
          ################################################

          define OWNAS = ${builtins.toString cfg.asn};
          define OWNIP = ${cfg.routerIp};
          define OWNNET = ${cfg.subnet};
          define OWNNETSET = [${cfg.subnet}+];

          ################################################
          #                 Header end                   #
          ################################################

          log syslog { warning, error, fatal };
          log "/var/log/bird/remote.log" { remote };
          log "/var/log/bird/bugs.log" { bug };
          log "/var/log/bird/trace.log" { trace };
          log "/var/log/bird/debug.log" { debug };
          log "/var/log/bird/info.log" { info };

          router id ${cfg.routerId};

          protocol device {
              scan time 10;
          }

          /*
            *  Utility functions
            */

          function is_self_net() -> bool {
            return net ~ OWNNETSET;
          }

          roa6 table dn42_roa;

          protocol static {
              roa6 { table dn42_roa; };
              include "${initialRoa}";
          };

          function is_valid_network() -> bool {
            return net ~ [
              fd00::/8{44,64} # ULA address space as per RFC 4193
            ];
          }

          protocol kernel {
              scan time 20;

              ipv6 {
                  import none;
                  export filter {
                      if source = RTS_STATIC then reject;
                      krt_prefsrc = OWNIP;
                      accept;
                  };
              };
          };

          protocol static {
              route OWNNET reject;

              ipv6 {
                  import all;
                  export none;
              };
          }

          template bgp dnpeers {
              local as OWNAS;
              path metric 1;

              ipv4 {
                import none;
                export none;
              };

              ipv6 {   
                  import filter {
                    if is_valid_network() && !is_self_net() then {
                      if (roa_check(dn42_roa, net, bgp_path.last) != ROA_VALID) then {
                        # Reject when unknown or invalid according to ROA
                        print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
                        reject;
                      } else accept;
                    } else reject;
                  };
                  export filter { if is_valid_network() && source ~ [RTS_STATIC, RTS_BGP] then accept; else reject; };
                  import limit 9000 action block; 
              };
          }

          ${lib.concatLines (
            lib.mapAttrsToList (asn: values: ''
              protocol bgp dn42_${lib.toLower asn} from dnpeers {
                  neighbor ${lib.head (lib.splitString "/" values.wireguard.EndPoint.PeerIP)} as ${asn};
                  ${lib.optionalString (
                    (lib.hasPrefix "fe80::" values.wireguard.EndPoint.PeerIP)
                    && (lib.hasSuffix "/64" values.wireguard.EndPoint.PeerIP)
                  ) "interface \"${getIfName asn}\";"}
              }
            '') cfg.peers
          )}
        '';
      };

    systemd.tmpfiles.settings = {
      "10-birdlogs" = {
        "/var/log/bird" = {
          d = {
            user = "bird";
            group = "bird";
            mode = "0755";
          };
        };
      };
    };
  };
}
