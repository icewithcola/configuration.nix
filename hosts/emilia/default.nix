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
    sshd.enable = true;
  };
}
