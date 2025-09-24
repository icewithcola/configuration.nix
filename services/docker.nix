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
  // lib.mkIf (config.kagura.rootFileSystem == "btrfs") {
    storageDriver = "btrfs"; # else use overlayfs
  };
}
