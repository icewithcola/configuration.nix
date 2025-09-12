{
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options = {
    asn = mkOption {
      type = types.int;
      example = 4242420833;
      description = "ASN number for this peer";
    };

    wireguard = {
      PublicKey = mkOption {
        type = types.str;
        description = "WireGuard public key for this peer";
      };

      EndPoint = {
        HostName = mkOption {
          type = types.str;
          example = "some.ddns.net";
          description = "WireGuard endpoint host name";
        };
        Port = mkOption {
          type = types.str;
          example = "22323";
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
