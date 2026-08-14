{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.kagura.wine.enable = lib.mkEnableOption "Wine compatibility tools";

  config = lib.mkIf config.kagura.wine.enable {
    environment.systemPackages = with pkgs; [
      wineWowPackages.stable
      wineWowPackages.waylandFull
      wine64
      winetricks
    ];
  };
}
