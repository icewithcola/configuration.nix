{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.kagura.sound.enable = lib.mkEnableOption "PipeWire audio support";

  config = lib.mkIf config.kagura.sound.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    environment.systemPackages = with pkgs; [
      qpwgraph
    ];
  };
}
