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
  ]);
}
