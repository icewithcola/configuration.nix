{ pkgs, lib, config, ... }:
let
  basePkgs = with pkgs; [
    eza
    yazi
    hyfetch
    btop
    gnupg
    zellij
  ];
  guiPkgs = with pkgs; [
    vlc
    tsukimi
    jadx
  ];
  tuiPkgs = with pkgs; [

  ];
  devPkgs = with pkgs; [
    bun
    typst
    gdb
    android-tools
  ];
in;
{
  home.packages = (
    basePkgs ++ lib.mkIf (config.kagura.home.targets == "gui", guiPkgs ++ lib.mkIf (config.kagura.home.targets.gui.dev, devPkgs)) ++ lib.mkIf (config.kagura.home.targets == "headless", tuiPkgs)
  );
}
