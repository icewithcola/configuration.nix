{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.niri = {
    package = pkgs.niri;
    settings = {
      hotkey-overlay.skip-at-startup = true;
      prefer-no-csd = true;

      outputs = {
        "eDP-1".scale = 1.15;
      };
      ayout = {
        default-column-width.proportion = 0.5;
        background-color = "transparent";
        always-center-single-column = true;
        focus-ring = {
          width = 2;
          active.color = "#5BCEFA";
          urgent.color = "#F5A9B8";
        };
      };
    };
  };
}
