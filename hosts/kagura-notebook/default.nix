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
    "activate-linux"
  ])
  ++ (enablePrograms [
    "clash-verge-rev"
    "fcitx5"
    "nix-ld"
    "steam"
    "wine"
    "incus"
  ])
  ++ (enableServices [
    "bluetooth"
    "sound"
    "virt"
  ]);
}
