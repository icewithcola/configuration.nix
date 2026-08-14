# https://github.com/AsterisMono/flake
# 呜呜给我抄太好了
{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    inputs.niri.nixosModules.niri
  ];

  options.kagura.niri.enable = lib.mkEnableOption "Niri compositor support";

  config = lib.mkIf config.kagura.niri.enable {
    security.pam.services.swaylock = { };

    programs = {
      niri = {
        enable = true;
        package = pkgs.niri;
      };
    };
  };
}
