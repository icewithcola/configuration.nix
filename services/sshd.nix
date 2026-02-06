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

    keys = mkOption {
      type = types.listOf types.str;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPt9ckkZVYhl21qSJlGoi7i9EyAD+VwL0Fq4rdRO8k6k kagura@KaguraPC"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFtsBUrTKcEIW2UZ2//QeU+PJj3/dxaVCncTg1j7gvAP kagura@kagura-notebook"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINM2PaIrCqinwe8nmbfEG/je6BZ6MYGndO0i5gtS89az kagura@mobile"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILvzvPkUD3wQUcRJf4C2JK6MWtGbKd001hUh710slauF kagura-tencent"
      ];
      description = "List of SSH keys to add to the authorized keys file.";
      example = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ..." ];
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
    users.users."${config.kagura.username}".openssh.authorizedKeys.keys = cfg.keys;
  };
}
