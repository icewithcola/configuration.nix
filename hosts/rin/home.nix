{ lib, pkgs, ... }:
let
  proxyRepo = "/home/kagura/repo/clash_config";
in
{
  imports = [ ../../home ];

  kagura.home.pkgSets = {
    network = true;
    dev = true;
  };

  systemd.user.services.proxy-update = {
    Unit.Description = "Check A/B proxies through br-cm and upload the selection";

    Service = {
      Type = "oneshot";
      WorkingDirectory = "${proxyRepo}/proxy-checker";
      ExecStart = "${lib.getExe pkgs.bash} ${proxyRepo}/proxy-checker/run.sh";
      Environment = [
        "PATH=${
          lib.makeBinPath [
            pkgs.nix
            pkgs.coreutils
            pkgs.bash
          ]
        }"
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      ];
      # The interactive launcher opens a terminal if it inherits display variables.
      UnsetEnvironment = [
        "DISPLAY"
        "WAYLAND_DISPLAY"
      ];
      TimeoutStartSec = "45min";
      UMask = "0077";
    };
  };

  systemd.user.timers.proxy-update = {
    Unit.Description = "Update selected proxy providers hourly";
    Timer = {
      OnCalendar = "hourly";
      OnStartupSec = "5min";
      Persistent = true;
      RandomizedDelaySec = "30s";
      Unit = "proxy-update.service";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
