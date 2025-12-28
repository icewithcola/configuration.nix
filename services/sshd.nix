{ lib, config, ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PrintMotd = true;
      PasswordAuthentication = false;
    };
  };
  users.motd = "NixOS Build ${lib.version}.";
}
