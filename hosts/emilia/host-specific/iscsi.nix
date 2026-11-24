{ lib, pkgs, ... }:
{
  systemd.services.iscsi-target = {
    after = [
      "mnt-data.mount"
      "tailscaled.service"
      "tailscaled-autoconnect.service"
    ];
    requires = [ "mnt-data.mount" ];
    wants = [
      "tailscaled.service"
      "tailscaled-autoconnect.service"
    ];
    unitConfig = {
      RequiresMountsFor = [ "/mnt/data" ];
      ConditionPathIsMountPoint = "/mnt/data";
      ConditionPathExists = "/mnt/data/iscsi.img";
    };

    # targetctl clear tears down live sessions. Apply target changes manually
    # only after ks has cleanly unmounted /mnt/ext.
    restartIfChanged = false;

    # Autoconnect waits for BackendState=Running; also require the exact local
    # address before targetctl restore binds the Tailscale-only portal.
    preStart = ''
      until ${lib.getExe' pkgs.iproute2 "ip"} -4 -o address show dev tailscale0 2>/dev/null \
        | ${lib.getExe pkgs.gnugrep} -Fq ' inet 100.79.31.14/'; do
        if (( SECONDS >= 120 )); then
          echo "Timed out waiting for 100.79.31.14 on tailscale0; refusing to restore iSCSI target" >&2
          exit 1
        fi
        ${lib.getExe' pkgs.coreutils "sleep"} 1
      done
    '';
    serviceConfig.TimeoutStartSec = "150s";
  };

  services.target = {
    enable = true;
    config = {
      storage_objects = [
        {
          name = "ks_vdisk";
          plugin = "fileio";
          dev = "/mnt/data/iscsi.img";
          size = 214748364800;
          wwn = "78571077-7378-424c-9f1f-aab0ef37b04f";
        }
      ];

      targets = [
        {
          fabric = "iscsi";
          wwn = "iqn.2026-03.emilia.dace-teeth.ts.net:storage-server";
          tpgs = [
            {
              tag = 1;
              enable = true;
              attributes = {
                authentication = 0;
                generate_node_acls = 0;
                demo_mode_write_protect = 0;
                cache_dynamic_acls = 1;
              };

              luns = [
                {
                  index = 0;
                  storage_object = "/backstores/fileio/ks_vdisk";
                }
              ];
              portals = [
                {
                  ip_address = "100.79.31.14";
                  port = 3260;
                }
              ];
              node_acls = [
                {
                  node_wwn = "iqn.1993-08.org.debian:01:56993966bc8d";
                  mapped_luns = [
                    {
                      index = 0;
                      tpg_lun = 0;
                      write_protect = false;
                    }
                  ];
                  attributes.authentication = 0;
                }
              ];
              parameter_dict = {
                AuthMethod = "None";
                GenerateNodeACLex = "0";
              };
            }
          ];
        }
      ];
    };
  };
}
