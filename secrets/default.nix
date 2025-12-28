{
  lib,
  age,
  config,
  ...
}:
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
        "loli-cer" = lib.mkIf config.services.nginx.enable {
          mode = "770";
          owner = "nginx";
          group = "nginx";
          file = ./loli-cer.age;
        };
        "loli-priv" = lib.mkIf config.services.nginx.enable {
          mode = "770";
          owner = "nginx";
          group = "nginx";
          file = ./loli-priv.age;
        };
      };

  age.identityPaths = [
    "/home/kagura/.ssh/id_ed25519"
    "/etc/ssh/id_ed25519"
  ];
}
