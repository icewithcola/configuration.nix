{ lib, ... }:
let
  enableHomeModule = (x: lib.map (s: ../../homeModules/${s}) x);
in
{
  imports = ([
    ../../home
  ])
  ++ (enableHomeModule [
    "niri"
    "waybar"
    "fuzzel"
  ]);

  kagura.home = {
    pkgSets = {
      gui = true;
      dev = true;
      network = true;
    };
  };
}
