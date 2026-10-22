{
  pkgs,
  pkgs-stable,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 7;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "kagura-notebook";
    networkmanager = {
      enable = true;
      settings.connectivity = {
        enabled = true;
        uri = "http://www.qualcomm.cn/generate_204";
        response = "";
      };
    };
    firewall.enable = false;
  };

  time.timeZone = "Asia/Shanghai";

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
      pinentry-all
      libreoffice-qt
      remmina
      kitty
      vscode
      rustup
      pkg-config
      openssl
      zlib
      cargo-binutils
      yarn
      texliveFull
      jdk25_headless
      jdk17_headless
      perl
      libgcc
      gcc14
      gnumake
      llvmPackages_20.clang-tools
      llvmPackages_20.clangUseLLVM
      android-studio
      # GFortran 16 adds a SPLIT intrinsic that shadows JTDX's subroutine.
      (jtdx.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./host-specific/jtdx-external-split.patch ];
      }))
      # ks serves this mirror from /var/www/blog/downloads, outside generated blog output.
      (kagura-pkgs.google-chrome-138.overrideAttrs (old: {
        src = old.src.overrideAttrs {
          urls = [
            "https://kagurach.uk/static/downloads/google-chrome-stable_${old.version}-1_amd64.deb"
          ];
        };
      }))
    ])
    ++ (with pkgs-stable; [ telegram-desktop ]);

  nixpkgs.config.allowUnfree = true;

  services = {
    xserver.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      # Use a 24-hour clock in the greeter while retaining KWin's layer-shell integration.
      settings.General.GreeterEnvironment = "QT_WAYLAND_SHELL_INTEGRATION=layer-shell,LC_TIME=en_GB.UTF-8";
    };
    desktopManager.plasma6.enable = true;
  };

  programs = {
    zsh.enable = true;
    niri.enable = true;

    npm = {
      enable = true;
      npmrc = ''
        prefix = ''${HOME}/.npm

        # Do not run dependency lifecycle hooks implicitly.
        ignore-scripts = true

        # Quarantine newly published package versions for one week.
        min-release-age = 7

        # Only the root project may opt into non-registry dependencies.
        allow-directory = root
        allow-file = root
        allow-git = root
        allow-remote = root

        # Keep dependency resolution reproducible and transport authenticated.
        package-lock = true
        save-exact = true
        strict-ssl = true
      '';
    };
  };

  zramSwap.enable = true;

  system.stateVersion = "24.05";
}
