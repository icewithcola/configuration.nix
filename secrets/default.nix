{ lib, age, config, ... }:
with lib;
let
  files = filter (x: hasSuffix ".age" x) (builtins.attrNames (builtins.readDir ./.));
in
{
  age.secrets =
    lib.recursiveUpdate
      (listToAttrs (
        map (
          name:
          let
            fileName = removeSuffix ".age" name;
          in
          {
            name = fileName;
            value.file = ./${name};
          }
        ) files
      ))
      {
        "loli-cer" = lib.mkIf config.services.nginx.enable  {
          mode = "770";
          owner = "nginx";
          group = "nginx";
        };
        "loli-priv" = lib.mkIf config.services.nginx.enable {
          mode = "770";
          owner = "nginx";
          group = "nginx";
        };
      };

  age.identityPaths = [
    "/home/kagura/.ssh/id_ed25519"
  ];
}
