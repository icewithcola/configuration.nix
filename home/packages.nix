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
    doggo # Alternative to dig
    rustscan # Alternative to nmap
    iperf
  ];

  dev = with pkgs; [
    typst
    gdb
    ripgrep

    antigravity-cli
    codex

    # Formatter, global
    nixfmt
    nil
    shfmt
  ];

  devAndroid = with pkgs; [
    android-tools
  ];
in
{
  home.packages =
    base
    ++ lib.optionals config.kagura.home.pkgSets.gui gui
    ++ lib.optionals config.kagura.home.pkgSets.network network
    ++ lib.optionals config.kagura.home.pkgSets.dev dev
    ++ lib.optionals config.kagura.home.pkgSets.devAndroid devAndroid;

  programs.direnv = lib.mkIf config.kagura.home.pkgSets.dev {
    enable = true;
    nix-direnv.enable = true;
  };
}
