{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages;
    kernelParams = [ "nomodeset" ];
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
        memtest86.enable = true;
      };
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };

    };
  };

  networking = {
    hostName = "rin";
    networkmanager = {
      enable = true;
      settings = {
        connectivity = {
          enabled = true;
          uri = "http://www.qualcomm.cn/generate_204";
          response = "";
        };
      };
    };
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

  environment.systemPackages =
    (with pkgs; [
    ])
    ++ (with pkgs-stable; [
    ]);

  nixpkgs.config.allowUnfree = true;

  # Desktop Environment
  services = {
    xserver.enable = false;
  };

  programs = {
    zsh.enable = true;
  };

  zramSwap.enable = false;

  system.stateVersion = "24.05";
}
