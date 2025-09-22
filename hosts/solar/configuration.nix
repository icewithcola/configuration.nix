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
      systemd-boot.enable = true;
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
    };
    kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;

      "net.ipv6.conf.all.accept_ra" = 0;
      "net.ipv6.conf.all.autoconf" = 0;
      "net.ipv6.conf.all.use_tempaddr" = 0;
    };
  };

  # https://github.com/ghostbuster91/blogposts/blob/a2374f0039f8cdf4faddeaaa0347661ffc2ec7cf/router2023-part2/main.md
  systemd.network = {
    wait-online.anyInterface = true;
    netdevs = {
      "20-br-lan" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-lan";
        };
      };
    };

    networks = {
      "10-enp1s0" = {
        matchConfig.Name = "enp1s0";
        networkConfig = {
          DHCP = "yes";
          DNSOverTLS = false;
          DNSSEC = false;
          IPv6PrivacyExtensions = false;
          IPForward = true;
        };
        linkConfig.RequiredForOnline = "routable";
      };
      "30-lan" = {
        matchConfig.Name = "enp2s0";
        linkConfig.RequiredForOnline = "enslaved";
        networkConfig = {
          ConfigureWithoutCarrier = true;
        };
      };
      "40-br-lan" = {
        matchConfig.Name = "br-lan";
        bridgeConfig = { };
        address = [
          "192.168.114.1/24"
        ];
        networkConfig = {
          ConfigureWithoutCarrier = true;
        };
      };
    };
  };
  networking = {
    hostName = "solar";
    useDHCP = false;

    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
          chain input {
            type filter hook input priority 0; policy drop;

            iifname { "br-lan" } accept comment "Allow local network to access the router"
            iifname "enp1s0" ct state { established, related } accept comment "Allow established traffic"
            iifname "enp1s0" icmp type { echo-request, destination-unreachable, time-exceeded } counter accept comment "Allow select ICMP"
            iifname "enp1s0" counter drop comment "Drop all other unsolicited traffic from enp1s0"
            iifname "lo" accept comment "Accept everything from loopback interface"
          }
          chain forward {
            type filter hook forward priority filter; policy drop;

            iifname { "br-lan" } oifname { "enp1s0" } accept comment "Allow trusted LAN to enp1s0"
            iifname { "enp1s0" } oifname { "br-lan" } ct state { established, related } accept comment "Allow established back to LANs"
          }
        }

        table ip nat {
          chain postrouting {
            type nat hook postrouting priority 100; policy accept;
            oifname "enp1s0" masquerade
          }
        }
      '';
    };

    nat.enable = false;
    firewall.enable = false;
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      # upstream DNS servers
      server = [
        "223.5.5.5"
        "8.8.8.8"
        "1.1.1.1"
      ];

      domain-needed = true;
      bogus-priv = true;
      no-resolv = true;

      cache-size = 1000;

      dhcp-range = [ "br-lan,192.168.114.25,192.168.114.254,24h" ];
      interface = "br-lan";
      dhcp-host = "192.168.114.1";

      local = "/lan/";
      domain = "lan";
      expand-hosts = true;

      no-hosts = true;
      address = "/solar.lan/192.168.114.1";
    };
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
