{ pkgs, config, ... }:
{
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker;
    storageDriver = config.kagura.rootFileSystem;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}
