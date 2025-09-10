{
  pkgs,
  lib,
  config,
  ...
}:
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
    # TODO
  ];
  devPkgs = with pkgs; [
    bun
    typst
    gdb
    android-tools
  ];
in
{
  home.packages =
    basePkgs
    ++ lib.optionals (config.kagura.home.type == "gui") guiPkgs
    ++ lib.optionals (config.kagura.home.type == "headless") tuiPkgs
    ++ lib.optionals config.kagura.home.dev devPkgs;
}
