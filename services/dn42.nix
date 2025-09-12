# https://github.com/AsterisMono/flake/blob/main/nixosModules/services/dn42.nix
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.kagura.dn42;
  getIfName = name: "dn42-${name}";
  getPort = asn: lib.strings.toInt (lib.removePrefix "42424" (builtins.toString asn)); # 4242420833 -> 20833
  getLocalAddr = # Wireguard local loopback
    asn: "fe80:4514:${lib.removePrefix "424242" (builtins.toString asn)}::1/64";
  generateNetworkdConfig =
    name: peer:
    let
      asn = builtins.toString peer.asn;
      networkdEntry = "peer-${name}";
      ifname = getIfName name;
    in
    {
      netdevs."${networkdEntry}" = {
        netdevConfig = {
          Name = ifname;
          Kind = "wireguard";
        };
        wireguardConfig = {
          ListenPort = getPort asn;
          PrivateKeyFile = cfg.wireguard.PrivateKey;
        };
        wireguardPeers = [
          {
            PublicKey = peer.wireguard.PublicKey;
            Endpoint = "${peer.wireguard.EndPoint.HostName}:${peer.wireguard.EndPoint.Port}";
            AllowedIPs = [
              "fd00::/8"
              "fe80::/10"
              "${peer.wireguard.EndPoint.MyIP}"
              "${peer.wireguard.EndPoint.PeerIP}"
            ];
            RouteTable = "off";
          }
        ];
      };
      networks."${networkdEntry}" = {
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
          "${getLocalAddr asn}"
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
        peersConfigList = lib.attrsets.mapAttrsToList generateNetworkdConfig cfg.peers;
        peersConfig = builtins.foldl' lib.recursiveUpdate {} peersConfigList;
      in
        lib.recursiveUpdate peersConfig
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
            lib.mapAttrsToList (name: peer: ''
              protocol bgp dn42_${name} from dnpeers {
                  neighbor ${lib.head (lib.splitString "/" peer.wireguard.EndPoint.PeerIP)} as ${builtins.toString peer.asn};
                  interface "${getIfName name}";
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
