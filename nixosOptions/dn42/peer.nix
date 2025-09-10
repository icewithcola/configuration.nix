{
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options = {
    ip6range = mkOption {
      type = types.str;
      description = "IPv6 range";
    };

    wireguard = {
      PublicKey = mkOption {
        type = types.str;
        description = "WireGuard public key";
      };

      EndPoint = {
        HostName = mkOption {
          type = types.str;
          description = "WireGuard endpoint host name";
        };
        Port = mkOption {
          type = types.int;
          description = "WireGuard endpoint port";
        };
        MyIP = mkOption {
          type = types.str;
          example = "fe80:1234:7::1/127";
          description = "WireGuard endpoint my IP address";
        };
        PeerIP = mkOption {
          type = types.str;
          example = "fe80:1234:7::10/127";
          description = "WireGuard endpoint peer IP address";
        };
      };
    };
  };
}
