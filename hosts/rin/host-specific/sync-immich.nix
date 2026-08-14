{
  lib,
  pkgs,
  ...
}:
{
  systemd = {
    services.immich-auto-backup = {
      description = "Back up Immich with seven daily restore points";

      path = [
        pkgs.coreutils
        pkgs.findutils
      ];

      script = ''
        set -eu
        SRC="/opt/immich-app/library"
        MIRROR="/mnt/ssd128/immich/library"
        HISTORY="/mnt/ssd128/immich/history"
        SNAPSHOT="$HISTORY/$(date -u +%Y-%m-%dT%H:%M:%SZ)"

        # Create a point-in-time copy before updating the mirror.  Unchanged
        # files are hard-linked to the mirror, so the seven restore points
        # consume space only for changed or deleted files.
        mkdir -p "$MIRROR" "$HISTORY"
        ${lib.getExe pkgs.rsync} -aHXc --link-dest="$MIRROR" "$SRC/" "$SNAPSHOT/"

        # Do not use --inplace here: changed files must be replaced so the
        # hard links retained by the history remain immutable restore points.
        ${lib.getExe pkgs.rsync} -aHXc --delete "$SRC/" "$MIRROR/"

        # Keep the newest seven daily restore points.  The timestamped names
        # are generated above, so sorting them is chronological.
        mapfile -t expired_snapshots < <(
          find "$HISTORY" -mindepth 1 -maxdepth 1 -type d \
            -name '????-??-??T??:??:??Z' -printf '%f\n' \
            | sort \
            | head -n -7
        )
        for snapshot in "''${expired_snapshots[@]}"; do
          rm -rf -- "$HISTORY/$snapshot"
        done
      '';

      unitConfig = {
        ConditionPathIsMountPoint = "/mnt/ssd128";
        RequiresMountsFor = "/mnt/ssd128";
      };

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
