{
  pkgs,
  lib,
  config,
  ...
}:
let
  basePkgs = with pkgs; [
    # Base = Every machine should have this
    eza
    yazi
    hyfetch
    btop
    gnupg
    zellij
  ];
  guiPkgs = with pkgs; [
    # GUI = Base Entertainment
    vlc
    moonlight-qt
    tsukimi
    jadx
  ];
  tuiPkgs = with pkgs; [
    gping # Alternative to ping
    doggo # Alternative to dig
    rustscan # Alternative to nmap
  ];
  devPkgs = with pkgs; [
    # Dev = Developer tools
    bun
    typst
    gdb
    android-tools

    # Formatter, global
    nixfmt
    nil
    shfmt
  ];
in
{
  home.packages =
    basePkgs
    ++ lib.optionals (config.kagura.home.type == "gui") guiPkgs
    ++ lib.optionals (config.kagura.home.type == "headless") tuiPkgs
    ++ lib.optionals config.kagura.home.dev devPkgs;
}
