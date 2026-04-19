{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mkIf
    mkMerge
    concatStringsSep
    optional
    optionals
    ;
  cfg = config.kagura.tailscale;
  useServerFeatures = (cfg.asExitNode) || (cfg.advertiseRoutes != [ ]);

in
{
  options.kagura.tailscale = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable tailscale";
    };

    tailnetName = mkOption {
      type = types.str;
      description = "The tailnet name of your network, like `a-b` and your domains will be `host.a-b.ts.net`";
    };

    asExitNode = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Use this device as tailscale exit node.
        Equivalent to `--advertise-exit-node` inside up flags
      '';
    };

    advertiseRoutes = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Route listed subnets with tailscale.
        Using `--advertise-routes=<>,<>` inside up flags
      '';
    };

    advertiseTags = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = ''
        Tags of this device.
        Using `--advertise-tags=<tag:<tagName>,...>` inside up flags
      '';
    };

    relayServerPort = mkOption {
      type = types.nullOr types.port;
      default = null;
      description = ''
        Use this device as a relay server using specific port.
        Equivalent to `--relay-server-port=<port>` inside set flags.
      '';
    };

    authKeyFile = mkOption {
      type = types.nullOr types.path;
      description = ''
        Auth key file of this machine
      '';
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = if useServerFeatures then "both" else "client";
      authKeyFile = cfg.authKeyFile;

      extraUpFlags = [ "--reset" ] 
        ++ optionals cfg.asExitNode [ "--advertise-exit-node" ]
        ++ optionals (cfg.advertiseRoutes != [ ]) [ "--advertise-routes=${concatStringsSep "," cfg.advertiseRoutes}" ]
        ++ optionals (cfg.advertiseTags != null) [ "--advertise-tags=${concatStringsSep "," (map (s: "tag:${s}") cfg.advertiseTags)}" ];
        
      extraSetFlags = optional (
        cfg.relayServerPort != null
      ) "--relay-server-port=${toString cfg.relayServerPort}";
    };

    networking = mkIf useServerFeatures {
      nftables.enable = true;
      firewall = {
        trustedInterfaces = [ "tailscale0" ];
        allowedUDPPorts = [
          config.services.tailscale.port
        ]
        ++ optional (cfg.relayServerPort != null) cfg.relayServerPort;
      };
    };

    systemd = mkIf useServerFeatures {
      services.tailscaled.serviceConfig.Environment = [
        "TS_DEBUG_FIREWALL_MODE=nftables"
      ];
      network.wait-online.enable = false;
    };

    boot = mkIf useServerFeatures {
      initrd.systemd.network.wait-online.enable = false;
    };
  };
}
