# https://github.com/Alexays/Waybar
# https://tangled.sh/@pluie.me/flake/tree/main/users/leah/presets/niri/waybar
{ lib, pkgs, ... }:
let
  interval = 2;
  icon = glyph: "<span font_family='Symbols Nerd Font Mono' size='large'>${glyph}</span>";
in
{
  home.packages = [ pkgs.nerd-fonts.symbols-only ];
  fonts.fontconfig.enable = true;

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      targets = [ "graphical-session.target" ];
    };
    style = ./style.css;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
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
          "group/status"
          "tray"
          "clock"
        ];

        "group/status" = {
          orientation = "horizontal";
          modules = [
            "cpu"
            "memory"
            "battery"
            "pulseaudio"
            "network"
          ];
        };

        # ── Left ──────────────────────────────────────────────

        "image" = {
          path = ../../home/assets/nix-snowflake-transgender.png;
          # Waybar 0.15 otherwise refreshes this static image every millisecond.
          interval = "once";
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
          format = "${icon "󰍛"}  {percentage}%";
          tooltip-format = "{used:0.1f}G / {total:0.1f}G";
        };

        cpu = {
          inherit interval;
          format = "${icon ""}  {usage}%";
          tooltip-format = "{avg_frequency} GHz";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "${icon "{icon}"}  {capacity}%";
          format-charging = "${icon "󰂄"}  {capacity}%";
          format-plugged = "${icon ""}  {capacity}%";
          format-full = "${icon ""}  {capacity}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          tooltip = true;
          tooltip-format = "{time}  ({power:.1f}W)";
        };

        pulseaudio = {
          format = "${icon "{icon}"}  {volume}%";
          format-muted = "${icon "󰝟"}  mute";
          format-icons = {
            headphone = "";
            headset = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          scroll-step = 5;
          tooltip = true;
          tooltip-format = "{desc}";
        };

        network = {
          format-wifi = "${icon ""}  {essid}";
          format-ethernet = "${icon "󰈀"}  {ifname}";
          format-disconnected = "${icon "󰖪"}  offline";
          format-alt = "${icon "󰈀"}  {ipaddr}";
          max-length = 24;
          tooltip-format-wifi = "{essid} · {signalStrength}%\n{ipaddr}/{cidr} via {gwaddr}";
          tooltip-format-ethernet = "{ifname}\n{ipaddr}/{cidr} via {gwaddr}";
          on-click-right = "nm-connection-editor";
        };

        tray = {
          icon-size = 18;
          spacing = 8;
        };

        clock = {
          format = "${icon ""}  {:%a %m-%d  %H:%M}";
          format-alt = "${icon ""}  {:%Y-%m-%d %H:%M:%S}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            on-scroll = 1;
          };
        };
      };
    };
  };

  systemd.user.services.waybar = {
    # Niri exports its socket before starting graphical-session.target.
    # Skip Waybar in Plasma, which also uses this target.
    Unit.ConditionEnvironment = lib.mkForce [
      "WAYLAND_DISPLAY"
      "NIRI_SOCKET"
    ];
    # Home Manager also adds tray.target; keep startup tied to session readiness.
    Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
  };
}
