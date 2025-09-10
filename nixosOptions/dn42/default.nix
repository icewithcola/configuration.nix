{
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.kagura.dn42 = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable dn42 service";
    };

    asn = mkOption {
      type = types.int;
      default = 4242422323;
      example = 4242422323;
      description = "ASN without AS prefix";
    };

    routerIp = mkOption {
      type = types.str;
      example = "fdcb:dded:cbcc::1";
      description = "Router IP address";
    };

    routerId = mkOption {
      type = types.str;
      example = "114.51.41.198";
      description = "Router ID";
    };

    subnet = mkOption {
      type = types.str;
      example = "fdcb:dded:cbcc::/48";
      description = "Subnet assigned to the asn";
    };

    wireguard = {
      PrivateKey = mkOption {
        type = types.str;
        example = "/run/keys/wireguard.key";
        description = "WireGuard private key, path or value";
      };
    };

    peers = mkOption {
      type = types.attrsOf (types.submodule (import ./peer.nix { inherit lib; }));
      default = { };
      description = "peer configurations";
    };
  };
}
