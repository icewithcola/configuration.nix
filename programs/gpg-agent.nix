{ lib, config, ... }:
{
  options.kagura.gpgAgent.enable = lib.mkEnableOption "GnuPG agent support";

  config = lib.mkIf config.kagura.gpgAgent.enable {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    services.pcscd.enable = true;
  };
}
