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
  generateWireguardConfig =
    name: peer:
    let
      ifname = getIfName name;
    in
    {
      interfaces."${ifname}" = {
        type = "wireguard";
        privateKeyFile = cfg.wireguard.PrivateKey;
        listenPort = getPort peer.asn;
        ips = [
          "${peer.wireguard.EndPoint.MyIP}"
        ];
        mtu = 1380;
        peers = [
          {
            name = "${name}";
            publicKey = peer.wireguard.PublicKey;
            endpoint = "${peer.wireguard.EndPoint.HostName}:${peer.wireguard.EndPoint.Port}";
            allowedIPs = [
              "fd00::/8"
              "fe80::/10"
              "${peer.wireguard.EndPoint.MyIP}"
              "${peer.wireguard.EndPoint.PeerIP}"
            ];
          }
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
    networking.wireguard =
      let
        peersConfigList = lib.attrsets.mapAttrsToList generateWireguardConfig cfg.peers;
        peersConfig = builtins.foldl' lib.recursiveUpdate { } peersConfigList;
      in
      lib.recursiveUpdate peersConfig {
        enable = true;
      };

    networking.networkmanager.ensureProfiles.profiles."dn42-dummy" =
      let
        subnet = lib.last (lib.splitString "/" cfg.subnet);
      in
      {
        connection = {
          autoconnect = "true";
          id = "dn42-dummy";
          interface-name = "dn42-dummy";
          type = "dummy";
        };
        ipv4 = {
          method = "disabled";
        };
        ipv6 = {
          addr-gen-mode = "default";
          address1 = "${cfg.routerIp}/${subnet}";
          method = "manual";
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

          function is_valid_ipv4(prefix net) -> bool {
            return net ~ [ 172.20.0.0/14{21,32} ];
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
              
              connect retry time 30;
              connect delay time 5;
              error wait time 60, 300;
              hold time 240;

              ipv4 {
                extended next hop on; 
                import filter {
                    if is_valid_ipv4(net) then accept; # 你需要定义一个 is_valid_ipv4 函数
                    reject;
                };
                export filter {
                    if source ~ [RTS_STATIC, RTS_BGP] then accept;
                    reject;
                }; 

                import limit 1000 action block;
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

    environment.systemPackages = [
      pkgs.wireguard-tools
    ];
  };
}
