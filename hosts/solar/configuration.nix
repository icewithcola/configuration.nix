{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}:
let
  thisIP = "192.168.114.1";
  thisIPv6 = "fc12:1145::1";
  predictableMac = "1A:2B:3C:4D:14:51";
in
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

      "net.ipv6.conf.enp1s0.accept_ra" = 2;
      "net.ipv6.conf.enp1s0.autoconf" = 1;
    };
  };

  networking = {
    hostName = "solar";
    useDHCP = false;
    nameservers = [
      "223.5.5.5"
      "1.1.1.1"
    ];

    bridges = {
      br0 = {
        interfaces = [
          "enp2s0"
        ];
      };
    };

    interfaces = {
      enp1s0.useDHCP = true;
      enp2s0.useDHCP = false;

      # Handle the VLANs
      br0 = {
        useDHCP = false;
        macAddress = predictableMac;
        ipv4.addresses = [
          {
            address = thisIP;
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = thisIPv6;
            prefixLength = 64;
          }
        ];
      };
    };

    nftables = {
      enable = true;
      flattenRulesetFile = true;
      preCheckRuleset = "sed 's/.*devices.*/devices = { lo }/g' -i ruleset.conf";
      ruleset = ''
        table inet filter {
          # enable flow offloading for better throughput
          flowtable f {
            hook ingress priority 0;
            devices = { enp1s0, br0 };
          }

          chain output {
            type filter hook output priority 100; policy accept;
          }

          chain input {
            type filter hook input priority filter; policy drop;

            # Allow trusted networks to access the router
            iifname {
              "br0",
            } counter accept

            # Allow returning traffic from enp1s0 and drop everthing else
            iifname "enp1s0" ct state { established, related } counter accept
            iifname "enp1s0" drop
          }

          chain forward {
            type filter hook forward priority filter; policy drop;

            # enable flow offloading for better throughput
            ip protocol { tcp, udp } flow offload @f

            # Allow trusted network WAN access
            iifname {
                    "br0",
            } oifname {
                    "enp1s0",
            } counter accept comment "Allow trusted LAN to WAN"

            # Allow established WAN to return
            iifname {
                    "enp1s0",
            } oifname {
                    "br0",
            } ct state established,related counter accept comment "Allow established back to LANs"
          }
        }

        table ip nat {
          chain prerouting {
            type nat hook prerouting priority filter; policy accept;
          }

          # Setup NAT masquerading on the enp1s0 interface
          chain postrouting {
            type nat hook postrouting priority filter; policy accept;
            oifname "enp1s0" masquerade
          }
        }
      '';
    };

    nat = {
      enable = true;
      externalInterface = "enp1s0";
      internalInterfaces = [ "br0" ];
      internalIPs = [ "${thisIP}/24" ];
      internalIPv6s = [ "${thisIPv6}/64" ];
    };

    firewall.enable = false;
  };

  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings = {

      domain-needed = true;
      bogus-priv = true;
      no-resolv = true;

      cache-size = 1000;

      dhcp-range = [ "192.168.114.25,192.168.114.254,24h" ];
      interface = "br0";
      dhcp-host = "${predictableMac},${thisIP}";

      local = "/lan/";
      domain = "lan";

      # DNS
      no-hosts = true;
      expand-hosts = true;
      server = [
        # upstream DNS servers
        "223.5.5.5"
        "8.8.8.8"
        "1.1.1.1"
      ];
      address = "/solar.lan/${thisIP}"; # Static dns entry
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
