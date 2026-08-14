{ lib, config, ... }:
{
  options.kagura.steam.enable = lib.mkEnableOption "Steam support";

  config = lib.mkIf config.kagura.steam.enable {
    programs.steam = {
      enable = true;
      protontricks.enable = true;
    };
  };
}
