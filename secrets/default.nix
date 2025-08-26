{ lib, age, ... }:
with lib;
let
  files = filter (x: hasSuffix ".age" x) (builtins.attrNames (builtins.readDir ./.));
in
{
  age.secrets = listToAttrs (
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
  );

  age.identityPaths = [
    "/home/kagura/.ssh/id_ed25519"
  ];
}
