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
    # Latest kernel
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "kagura-nas";
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

  # NAS Environment
  services = {
    xserver.enable = false;
  };

  programs = {
    zsh.enable = true;
  };

  zramSwap.enable = true;

  system.stateVersion = "24.05";
}
