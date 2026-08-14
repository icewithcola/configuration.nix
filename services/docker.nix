{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.kagura.docker.enable = lib.mkEnableOption "Docker support";

  config = lib.mkIf config.kagura.docker.enable {
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
  };
}
