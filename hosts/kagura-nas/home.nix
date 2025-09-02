{ lib, ... }:
let
  enableHomeModule = (x: lib.map (s: ../../homeModules/${s}) x);
in
{
  imports = (enableHomeModule [
  ]) ++ [
    ../../home/terminal
  ];

  programs.home-manager.enable = true;

  home = {
    sessionVariables = {
      EDITOR = "hx";
    };

    packages = with pkgs; [
      eza
      yazi
      hyfetch
      btop
      zellij
    ];

    username = "kagura";
    homeDirectory = "/home/kagura";
    stateVersion = "24.11";
  };

}
