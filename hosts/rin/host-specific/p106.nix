{
  config,
  lib,
  pkgs,
  ...
}: {
  hardware = {
    nvidia = {
      enabled = true;
      nvidiaSettings = false;
      nvidiaPersistenced = true;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580; # https://github.com/NixOS/nixpkgs/commit/893218f404d979b7cb87afab8aa656f5a5d7ca91
    };
  };
}
