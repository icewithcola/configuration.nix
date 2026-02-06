{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.kagura.sshd;
in
{
  options.kagura.sshd = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable SSH daemon.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PrintMotd = true;
        PasswordAuthentication = false;
      };
    };
    users.motd = "NixOS Build ${lib.version}.";
  };
}
