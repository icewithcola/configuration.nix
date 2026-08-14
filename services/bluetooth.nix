{ lib, config, ... }:
{
  options.kagura.bluetooth.enable = lib.mkEnableOption "Bluetooth support";

  config = lib.mkIf config.kagura.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };

    services.blueman.enable = true;
  };
}
