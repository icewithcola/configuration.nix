{ lib, config, ... }:
{
  options.kagura.sunshine.enable = lib.mkEnableOption "Sunshine game streaming";

  config = lib.mkIf config.kagura.sunshine.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };
  };
}
