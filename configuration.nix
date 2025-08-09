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

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Nix GC Configuration
    gc = {
      automatic = true;
      dates = "weekly";
      options = "-d";
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

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      noto-fonts-color-emoji
      noto-fonts-extra
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      meslo-lgs-nf
      kaguraRepo.HarmonyOS-Sans-fonts
      kaguraRepo.noto-fonts-cjk-sans-static
    ];
    fontconfig.defaultFonts = {
      serif = [
        "Noto Serif"
        "Noto Serif CJK SC"
        "Noto Color Emoji"
      ];

      sansSerif = [
        "Noto Sans"
        "Noto Sans CJK SC"
        "Noto Color Emoji"
      ];

      emoji = [
        "Noto Color Emoji"
      ];
    };
  };

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
      # Basic system utility
      helix
      wget
      curl
      zsh
      git
      coreutils
      usbutils
      pciutils

      pinentry-all # Used by gnupg

      # Desktop environment
      libreoffice-qt6-fresh
      remmina
      kitty
      clash-verge-rev
      vscode

      # Dev tools
      rustup
      clang-tools
      pkg-config
      openssl
      zlib
      cargo-binutils
      yarn

      # LateX
      texlive.combined.scheme-full

      # Develop packages
      jdk
      perl
      libgcc
      gcc14
      llvm_18
      lldb_18
      clang_18
      gnumake

      python3Full

    ])
    ++ (with pkgs-stable; [
      # 这下面放些不想更新的
      telegram-desktop
      google-chrome
      jetbrains-toolbox
      android-studio
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
  };

  zramSwap.enable = true;

  system.stateVersion = "24.05";
}
