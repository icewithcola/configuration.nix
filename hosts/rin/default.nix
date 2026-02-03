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
    "sshd"
    "ddns"
    "docker"
    "dn42"
  ]);

  kagura = {
    rootFileSystem = "ext4";
  };

  kagura.ddns = {
    cu = {
      host = "rin";
      secretFile = config.age.secrets.ddns-token.path;
      interface = "enp7s0f0";
      recordId = "c458e5e1fcbea062d8713af43c75de71";
    };
  };
}
