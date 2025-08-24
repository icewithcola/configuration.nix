{
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.niri.homeModules.config ./binds.nix ./settings.nix ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  services.xserver.displayManager.gdm.enable = true;
}