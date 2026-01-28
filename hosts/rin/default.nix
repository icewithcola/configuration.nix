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
    "incus"
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
    enable = true;
    host = "rin";
    secretFile = config.age.secrets.ddns-token.path;
    interface = "enp7s0f0";
  };
}
