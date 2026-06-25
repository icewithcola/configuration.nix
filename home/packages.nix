{
  pkgs,
  lib,
  config,
  ...
}:
let
  base = with pkgs; [
    # Base = Every machine should have this
    eza
    yazi
    hyfetch
    btop
    gnupg
    zellij
    jq
  ];

  gui = with pkgs; [
    vlc
    moonlight-qt
    tsukimi
    jadx
  ];

  network = with pkgs; [
    gping # Alternative to ping
    doggo   # Alternative to dig
    rustscan # Alternative to nmap
    iperf
  ];

  dev = with pkgs; [
    typst
    gdb
    android-tools
    ripgrep

    antigravity-cli

    # Formatter, global
    nixfmt
    nil
    shfmt
  ];
in
{
  home.packages =
    base
    ++ lib.optionals config.kagura.home.pkgSets.gui gui
    ++ lib.optionals config.kagura.home.pkgSets.network network
    ++ lib.optionals config.kagura.home.pkgSets.dev dev;
}
