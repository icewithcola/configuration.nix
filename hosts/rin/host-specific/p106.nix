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
    };
  };
}