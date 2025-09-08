{ lib, config, ... }:
let
  enableHomeModule = (x: lib.map (s: ../../homeModules/${s}) x);
in
{
  imports = ([
    ../../home
  ])
  ++ (enableHomeModule [

  ]);

  config.config.kagura.home.targets = "tui";
  config.kagura.home.targets.gui.dev = false;
}
