{ pkgs, ... }:
{

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker;
    storageDriver = "btrfs";
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
