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
  ])
  ++ (enableNixOSModule [
  ])
  ++ (enablePrograms [
  ])
  ++ (enableServices [
    "sshd"
    "ddns"
  ]);

  kagura.ddns = {
    enable = false;
    host = "rin";
    secretFile = config.age.secrets.ddns-token.path;
    interface = "enp2s0";
  };
}
