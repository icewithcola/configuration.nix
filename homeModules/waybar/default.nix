# https://github.com/Alexays/Waybar
{ pkgs, ... }:
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
        margin-top = 4;
        margin-bottom = 4;
        reload_style_on_change = true;
        spacing = 0;
        modules-left = [
          "image"
          "wlr/taskbar"
          "niri/window"
          "mpris"
        ];
        modules-center = [
          "niri/workspaces"
        ];
        modules-right = [
          "clock"
          "memory"
          "cpu"
          "battery"
          "network"
          "tray"
        ];

        # Module configuration: Left
        "image" = {
          path = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
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
            "" = "<span foreground='#89b4fa'> Niri</span>";
            " " = "<span foreground='#89b4fa'> Niri</span>";
            "(.*)" = "<span foreground='#89b4fa'>$1</span>";
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
          interval = 30;
          format = "MEM: {percentage}%";
        };
        cpu = {
          interval = 30;
          format = "CPU: {usage}%";
        };
        battery = {
          states = {
            warning = 30;
            critical = 20;
          };
          format = "{capacity}%";
          format-charging = "{capacity}%+";
          format-plugged = "plugged";
          tooltip-format = "{time}";
          tooltip = true;
        };
        tray = {
          icon-size = 18;
          spacing = 10;
        };
      };
    };
  };
}
