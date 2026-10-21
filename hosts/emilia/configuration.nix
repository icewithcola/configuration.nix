{
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    (modulesPath + "/profiles/minimal.nix")
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages;
    kernelParams = [ "nomodeset" ];
    loader.grub = {
      enable = true;
      device = "/dev/vda";
    };
  };

  networking = {
    hostName = "emilia";
    useDHCP = false;
    interfaces.ens18 = {
      ipv4.addresses = [
        {
          address = "94.249.150.12";
          prefixLength = 24;
        }
      ];
      ipv6.addresses = [
        {
          address = "2a12:bec4:1651:104::ca7";
          prefixLength = 48;
        }
        {
          address = "2a12:bec4:1651:104::555";
          prefixLength = 48;
        }
      ];
    };

    defaultGateway = "94.249.150.1";
    defaultGateway6 = {
      address = "2a12:bec4:1651::1";
      interface = "ens18";
    };
    nameservers = [
      "1.1.1.1"
      "2606:4700:4700::1111"
      "8.8.8.8"
    ];
    firewall.enable = false;
  };

  time.timeZone = "Asia/Shanghai";

  users.users.kagura = {
    isNormalUser = true;
    home = "/home/kagura";
    extraGroups = [
      "wheel"
      "kvm"
      "incus-admin"
      "docker"
      "libvirtd"
    ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  services.xserver.enable = false;
  programs.zsh.enable = true;

  zramSwap.enable = false;

  documentation.enable = false;
  fonts.fontconfig.enable = false;

  nix = {
    # Keep nixpkgs pinned without rooting its source tree in every generation.
    registry.nixpkgs.to = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      inherit (inputs.nixpkgs) rev narHash;
    };
    # Collect unused paths daily, retaining the existing seven-day rollback window.
    gc.dates = lib.mkForce "daily";
    optimise.automatic = true;
    # Reclaim unused paths during builds before the system disk fills up.
    settings = {
      min-free = 512 * 1024 * 1024;
      max-free = 1024 * 1024 * 1024;
    };
  };

  services.journald.settings.Journal = {
    SystemMaxUse = "100M";
    SystemKeepFree = "512M";
    RuntimeMaxUse = "32M";
  };

  system.stateVersion = "24.05";
}
