{
  pkgs,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages;
    kernelParams = [ "nomodeset" "memmap=4M$0x1572400000" ];
    loader = {
      systemd-boot.enable = true;
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
    };
    tmp.useTmpfs = true;
  };

  networking = {
    hostName = "rin";
    networkmanager = {
      enable = true;
      settings.connectivity = {
        enabled = true;
        uri = "http://www.qualcomm.cn/generate_204";
        response = "";
      };
      ensureProfiles.profiles = {
        "br-cm" = {
          connection = {
            id = "br-cm";
            type = "bridge";
            interface-name = "br-cm";
          };
          ipv4.method = "auto";
        };

        "br-cm-slave" = {
          connection = {
            id = "br-cm-slave";
            type = "ethernet";
            interface-name = "enp8s0";
            master = "br-cm";
            slave-type = "bridge";
          };
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

  services = {
    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [ "/mnt/ssd128" ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  services.xserver.enable = false;
  programs.zsh.enable = true;

  zramSwap.enable = false;

  # Keep the existing responsive governor so container/VM workloads can still
  # boost normally.  The machine's C3 and C6 states are present in intel_idle
  # but currently disabled, which prevents the Xeon from reaching low-power
  # idle states between requests.
  powerManagement.cpuFreqGovernor = "schedutil";

  systemd.services.enable-deep-cpu-idle = {
    description = "Enable supported deep CPU idle states";
    wantedBy = [ "multi-user.target" ];
    before = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";

    script = ''
      for state in /sys/devices/system/cpu/cpu*/cpuidle/state*; do
        [ -r "$state/name" ] || continue

        case "$( ${pkgs.coreutils}/bin/cat "$state/name" )" in
          C3|C6)
            echo 0 > "$state/disable"
            ;;
        esac
      done
    '';
  };

  system.stateVersion = "24.05";
}
