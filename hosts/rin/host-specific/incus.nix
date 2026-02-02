{
  config,
  lib,
  pkgs,
  ...
}:

{
  virtualisation.incus = {
    enable = true;
    preseed = {
      networks = [ ];
      profiles = [
        {
          devices = {
            eth0 = {
              name = "eth0";
              nictype = "bridged";
              parent = "br-cm";
              type = "nic";
            };
            root = {
              path = "/";
              pool = "default";
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
