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
        device = "/dev/vda";
      };
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
