# https://github.com/AsterisMono/flake
# 呜呜给我抄太好了
{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.niri.nixosModules.niri
  ];

  security.pam.services.swaylock = { };

  programs = {
    niri = {
      enable = true;
      package = pkgs.niri;
    };
  };
}
