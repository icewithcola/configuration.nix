{
  lib,
  inputs,
  ...
}:
let
  enableNixOSModule = (x: lib.map (s: ../../nixosModules/${s}) x);
  enablePrograms = (x: lib.map (s: ../../programs/${s}.nix) x);
  enableServices = (x: lib.map (s: ../../services/${s}.nix) x);
in
{
  imports = ([
    ./configuration.nix
  ])
  ++ (enableNixOSModule [
    "niri"
  ]) ++ (enablePrograms [
    "clash-verge-rev"
    "fcitx5"
    "nix-ld"
    "steam"
    "wine"
  ]) ++ (enableServices [
    "bluetooth"
    "sound"
    "virt"
  ]);
}
