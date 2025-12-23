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
    hostName = "kagura-notebook";
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

  # Btrfs scrub
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

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
      pinentry-all # Used by gnupg

      # Desktop environment
      libreoffice-qt6-fresh
      remmina
      kitty
      vscode

      # Dev tools
      rustup
      pkg-config
      openssl
      zlib
      cargo-binutils
      yarn

      # LateX
      texlive.combined.scheme-full

      # Develop packages
      jdk25_headless
      jdk17_headless

      perl
      libgcc
      gcc14
      gnumake

      llvmPackages_20.clang-tools
      llvmPackages_20.clangUseLLVM

      # IDE like items
      android-studio
      jtdx

      kagura-pkgs.google-chrome-138
    ])
    ++ (with pkgs-stable; [
      # 这下面放些不想更新的
      telegram-desktop
    ]);

  nixpkgs.config.allowUnfree = true;

  # Desktop Environment
  services = {
    xserver.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    desktopManager.plasma6.enable = true;
  };

  programs = {
    zsh.enable = true;
    niri.enable = true;
  };

  zramSwap.enable = true;

  system.stateVersion = "24.05";
}
