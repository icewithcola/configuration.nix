{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.file = {
    ".gnupg/dirmngr.conf".text =
      lib.generators.toKeyValue
        {
          mkKeyValue =
            key: value: (if lib.isString value then "${key} ${value}" else lib.optionalString value key);
          listsAsDuplicateKeys = true;
        }
        {
          keyserver = "hkps://keyserver.ubuntu.com";
        };
  };
}
