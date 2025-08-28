# https://github.com/Alexays/Waybar
# https://tangled.sh/@pluie.me/flake/tree/main/users/leah/presets/niri/waybar
{ pkgs, ... }:
let
  interval = 10;
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
        spacing = 0;
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

        # Module configuration: Left
        "image" = {
          path = ../../home/assets/nix-snowflake-transgender.png;
          on-click = "niri msg action toggle-overview";
          size = 22;
          tooltip = false;
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
        "wlr/taskbar" = {
          all-outputs = false;
          format = "{icon}";
          icon-theme = "Papirus-Dark";
          icon-size = 16;
          tooltip = true;
          tooltip-format = "{title}";
          active-first = true;
          on-click = "activate";
        };
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

        # Module configuration: Center
        clock = {
          format = "<b>{:%a %m-%d %H:%M}</b>";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%H:%M %Y-%m-%d}";
        };

        # Module configuration: Right
        network = {
          format-wifi = "wifi: {essid}";
          format-ethernet = "eth: ";
          tooltip-format = "{essid} ({signalStrength}%)";
          format-disconnected = "emm: ";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        memory = {
          inherit interval;
          format = "MEM: {percentage}%";
        };
        cpu = {
          inherit interval;
          format = "CPU: {usage}%";
        };
        battery = {
          states = {
            warning = 30;
            critical = 20;
          };
          format = "{capacity}%";
          format-charging = "{capacity}%+";
          format-plugged = "{capacity}%~";
          tooltip-format = "{time}";
          tooltip = true;
        };
        pulseaudio = {
          "format" = "vol: {volume}%";
        };
        tray = {
          icon-size = 18;
          spacing = 10;
        };
      };
    };
  };
}
