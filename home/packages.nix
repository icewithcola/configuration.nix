{ pkgs, lib, ... }:
{
  home.packages = (
    with pkgs;
    [
      # TUI packages
      eza
      yazi
      hyfetch
      btop
      gnupg
      tmux

      # Devenv
      bun
      typst
      gdb
      android-tools

      # GUI Apps that runs
      vlc
      tsukimi
      jadx
    ]
  );
}
