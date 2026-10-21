{ lib, pkgs, ... }:
{
  imports = [ ../../home ];

  # Replace the shared package groups with tools suited to a small headless VPS.
  disabledModules = [ ../../home/packages.nix ];
  home.packages = with pkgs; [
    eza
    btop
    gnupg
    zellij
    jq
    gping
    doggo
    rustscan
    iperf
  ];

  kagura.home.pkgSets.network = true;

  programs.kitty.enable = lib.mkForce false;
  programs.man.enable = false;
  manual.manpages.enable = false;
  fonts.fontconfig.enable = false;
  xdg.mime.enable = false;
}
