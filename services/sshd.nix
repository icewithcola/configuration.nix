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

  users.users.kagura.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPt9ckkZVYhl21qSJlGoi7i9EyAD+VwL0Fq4rdRO8k6k kagura@KaguraPC"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO0x1Aac27t97e2CEQ1Oq2LshBCTKo8UN4ufydYKg/tG this@nkid00.name"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFtsBUrTKcEIW2UZ2//QeU+PJj3/dxaVCncTg1j7gvAP kagura@kagura-notebook"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINM2PaIrCqinwe8nmbfEG/je6BZ6MYGndO0i5gtS89az mobile"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILvzvPkUD3wQUcRJf4C2JK6MWtGbKd001hUh710slauF kagura-tencent"
  ];
}
