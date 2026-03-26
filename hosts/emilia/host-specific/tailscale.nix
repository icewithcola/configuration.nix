{ lib, config, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraUpFlags = [
      "--advertise-exit-node"
      "--advertise-tags=tag:relays-global"
    ];
    extraSetFlags = [
      "--relay-server-port=32457"
    ];
    authKeyFile = config.age.secrets.tailscale-emilia.path;
  };

  networking.nftables.enable = true;
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;
}
