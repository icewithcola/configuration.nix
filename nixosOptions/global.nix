{
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.kagura = {
    rootFileSystem = mkOption {
      type = types.enum [
        "ext4"
        "btrfs"
      ];
      description = "The file system of root";
    };
  };
}
