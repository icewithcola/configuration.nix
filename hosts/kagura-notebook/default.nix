{
  lib,
  inputs,
  ...
}:
let
  enableNixOSModule = (x: lib.map (s: ../../nixosModules/${s}) x);

in
{
  imports = ([
    ./configuration.nix
  ])
  ++ (enableNixOSModule [
    "niri"
  ]);
}
