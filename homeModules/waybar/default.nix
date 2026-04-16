# https://github.com/Alexays/Waybar
# https://tangled.sh/@pluie.me/flake/tree/main/users/leah/presets/niri/waybar
{ pkgs, ... }:
let
  interval = 2;
in
{
  programs.waybar = {
    enable = true;
    style = ./style.css;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        mod = "dock";
        margin-left = 15;
        margin-right = 15;
        margin-top = 2;
        margin-bottom = 0;
        reload_style_on_change = true;
        spacing = 4;

        modules-left = [
          "image"
          "wlr/taskbar"
          "mpris"
          "niri/workspaces"
        ];
        modules-center = [
          "niri/window"
        ];
        modules-right = [
          "memory"
          "cpu"
          "battery"
          "pulseaudio"
          "network"
          "tray"
          "clock"
        ];

        # ── Left ──────────────────────────────────────────────

        "image" = {
          path = ../../home/assets/nix-snowflake-transgender.png;
          on-click = "niri msg action toggle-overview";
          size = 22;
          tooltip = false;
        };

        "wlr/taskbar" = {
          all-outputs = false;
          format = "{icon}";
          icon-theme = "Papirus-Dark";
          icon-size = 18;
          tooltip = true;
          tooltip-format = "{title}";
          active-first = true;
          on-click = "activate";
        };

        "mpris" = {
          format = "  {artist} – {title}";
          format-paused = "  {artist} – {title}";
          format-stopped = "";
          player-icons = {
            default = "▶";
            mpv = "🎵";
          };
          status-icons = {
            paused = "";
          };
          max-length = 40;
          tooltip = true;
          tooltip-format = "{player}: {status}";
        };

        "niri/workspaces" = {
          all-outputs = false;
          on-click = "activate";
          current-only = false;
          disable-scroll = false;
          icon-theme = "Papirus-Dark";
          format = "<span><b>{icon}</b></span>";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
          };
        };

        # ── Center ────────────────────────────────────────────

        "niri/window" = {
          max-length = 50;
          format = "{app_id}";
          separate-outputs = true;
          rewrite = {
            "" = "<span foreground='#f5c2e7'>Niri</span>";
            " " = "<span foreground='#f5c2e7'>Niri</span>";
            "(.*)" = "<span foreground='#f5c2e7'>$1</span>";
          };
        };

        # ── Right ─────────────────────────────────────────────

        memory = {
          inherit interval;
          format = " {percentage}%";
          tooltip-format = "{used:0.1f}G / {total:0.1f}G";
        };

        cpu = {
          inherit interval;
          format = " {usage}%";
          tooltip-format = "{avg_frequency} GHz";
        };

        battery = {
          states = {
            full = 98;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-full = " {capacity}%";
          format-icons = [ "" "" "" "" "" ];
          tooltip = true;
          tooltip-format = "{time}  ({power:.1f}W)";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 mute";
          format-icons = {
            default = [ "" "" "" ];
          };
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          scroll-step = 5;
          tooltip = true;
          tooltip-format = "{desc}";
        };

        network = {
          format-wifi = " {essid} {signalStrength}%";
          format-ethernet = "󰈀 {ifname}";
          format-disconnected = "󰖪 offline";
          format-alt = " {ipaddr}/{cidr}";
          tooltip-format = "{essid} ({signalStrength}%) via {gwaddr}";
          on-click-right = "nm-connection-editor";
        };

        tray = {
          icon-size = 18;
          spacing = 8;
        };

        clock = {
          format = "<b>{:%a %m-%d %H:%M}</b>";
          format-alt = "{:%Y-%m-%d %H:%M:%S}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            on-scroll = 1;
          };
        };
      };
    };
  };
}
