{
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.kagura = {
    username = mkOption {
      type = types.str;
      description = "The username of this device";
      default = "kagura";
      example = "kagura";
    };

    hostname = mkOption {
      type = types.str;
      description = "The hostname of this device";
    };

    rootFileSystem = mkOption {
      type = types.enum [
        "ext4"
        "btrfs"
      ];
      description = "The file system of root";
    };
  };
}
