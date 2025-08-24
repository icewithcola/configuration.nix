{
  lib,
  inputs,
  ...
}:
let
  enableModules = 
    [
      # "niri"
    ];
in
{
  imports = ([
    ./configuration.nix
  ]) ++ (lib.map (x: ../../modules/${x} ) enableModules);
}
