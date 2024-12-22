# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports =
    [ 
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
    settings.experimental-features = [ "nix-command" "flakes" ];
        
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
          enabled  = true;
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

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;
  

  users.users.kagura = {
    isNormalUser = true;
    home = "/home/kagura";
    extraGroups = [ "wheel" "kvm" "incus-admin" "docker" "libvirtd" ];
    shell = pkgs.zsh;
   };
  
  environment.systemPackages = (with pkgs; [
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

    clash-verge-rev # Latest version GUI crash

    # Develop packages  
    jdk
    perl
    libgcc
    gcc14
    llvm_18
    lldb_18
    clang_18
    gnumake
  ]) ++ (with pkgs-unstable; [
    python3Full
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

  virtualisation.docker = {
    enable = true;
    package = pkgs-unstable.docker;
    storageDriver = "btrfs";
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

