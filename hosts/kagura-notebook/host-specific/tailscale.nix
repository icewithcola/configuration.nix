{ lib, config, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    authKeyFile = config.age.secrets.tailscale-kagura-notebook.path;
  };
}
