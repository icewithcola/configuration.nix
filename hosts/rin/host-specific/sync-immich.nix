{
  lib,
  pkgs,
  ...
}:
{
  systemd = {
    services.immich-auto-backup = {
      description = "Automatically backup immich";

      script = ''
        set -eu
        SRC="/opt/immich-app/library"
        DST="/mnt/ssd128/immich/library"

        ${lib.getExe pkgs.rsync} -aHXc --inplace --delete "$SRC" "$DST"
      '';

      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };

    timers.immich-auto-backup = {
      description = "Timer for automated SSD backup";
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "15m";
        Unit = "immich-auto-backup.service";
      };
    };
  };
}
