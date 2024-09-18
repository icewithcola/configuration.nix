{ config, lib, pkgs, ... }:

{
  virtualisation.incus = {
    enable = true;
    preseed = {
      networks = [
        {
          config = {
          "ipv4.address" = "192.168.100.1/24";
          "ipv4.nat" = "true";
        };
        name = "incusbr0";
        type = "bridge";
        }
      ];
      profiles = [
        {
          devices = {
            eth0 = {
              name = "eth0";
              network = "incusbr0";
              type = "nic";
            };
            root = {
              path = "/";
              pool = "default";
              size = "50GiB";
              type = "disk";
            };
          };
          name = "default";
        }
      ];
      storage_pools = [
        {
          config = {
            source = "/var/lib/incus/storage-pools/default";
          };
          driver = "dir";
          name = "default";
        }
      ];
    };
  };
}

