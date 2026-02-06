{
  lib,
  inputs,
  config,
  ...
}:
let
  enableNixOSModule = (x: lib.map (s: ../../nixosModules/${s}) x);
  enablePrograms = (x: lib.map (s: ../../programs/${s}.nix) x);
  enableServices = (x: lib.map (s: ../../services/${s}.nix) x);
in
{
  imports = ([
    ./configuration.nix
    ./host-specific
  ])
  ++ (enableNixOSModule [
  ])
  ++ (enablePrograms [
  ])
  ++ (enableServices [
  ]);

  kagura = {
    rootFileSystem = "ext4";
    sshd = {
      enable = true;
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPt9ckkZVYhl21qSJlGoi7i9EyAD+VwL0Fq4rdRO8k6k kagura@KaguraPC"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO0x1Aac27t97e2CEQ1Oq2LshBCTKo8UN4ufydYKg/tG this@nkid00.name"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFtsBUrTKcEIW2UZ2//QeU+PJj3/dxaVCncTg1j7gvAP kagura@kagura-notebook"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINM2PaIrCqinwe8nmbfEG/je6BZ6MYGndO0i5gtS89az mobile"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILvzvPkUD3wQUcRJf4C2JK6MWtGbKd001hUh710slauF kagura-tencent"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYFmnBe6VIe2UjpG6UqnsCZ45VBK4eRfMIvm+A/aNd4 kagura-home-devs"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICUTn8X8Zuwf8W9QsPIzKxzpXV1/BIVOuHB9WnnBkCec ks"
      ];
    };
  };
}
