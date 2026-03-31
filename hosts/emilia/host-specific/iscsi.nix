{ config, ... }:
{
  services.target = {
    enable = true;
    config = {
      storage_objects = [
        {
          name = "ks_vdisk";
          plugin = "fileio";
          dev = "/mnt/data/iscsi.img";
          size = 53687091200;
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
                authentication = 0; # 必须设为 0，否则它会无视 AuthMethod=None
                generate_node_acls = 0; # 既然手动写了 ACL，就关掉自动生成
                demo_mode_write_protect = 0; # 确保不是只读模式
                cache_dynamic_acls = 1; # 提升性能
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
                  attributes = {
                    authentication = 0;
                  };
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
