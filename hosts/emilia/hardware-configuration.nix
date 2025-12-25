{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/99de1f64-5129-49f2-9a86-34cefafecda7";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6e5f1ca9-7b48-4110-9f2a-595f26619c14";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/3d876532-b27c-4ccb-ac65-418faa27e52c"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
