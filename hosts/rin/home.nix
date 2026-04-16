{ lib, ... }:
let
  enableHomeModule = (x: lib.map (s: ../../homeModules/${s}) x);
in
{
  imports = ([
    ../../home
  ]);

  kagura.home = {
    pkgSets = {
      network = true;
    };
  };
}
