{ lib, ... }:
let
  enableHomeModule = (x: lib.map (s: ../../homeModules/${s}) x);
in
{
  imports = ([
    ../../home
  ])
  ++ (enableHomeModule [

  ]);

  kagura.home = {
    type = "minimal";
    dev = false;
  };
}
