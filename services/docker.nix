{
  lib,
  pkgs,
  config,
  ...
}:
{
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  }
  // lib.optionalAttrs (config.kagura.rootFileSystem == "btrfs") {
    storageDriver = "btrfs"; # else use overlayfs
  };
}
