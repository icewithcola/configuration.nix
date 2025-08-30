{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.niri = {
    package = pkgs.niri;
    settings = {
      hotkey-overlay.skip-at-startup = true;
      prefer-no-csd = true;

      outputs = {
        "eDP-1".scale = 1;
      };

      spawn-at-startup = [
        { command = [ "${lib.getExe pkgs.xwayland-satellite}" ]; }
        { command = [ "${lib.getExe pkgs.waybar}" ]; }
        { command = [ "${lib.getExe pkgs.mako}" ]; }
      ];

      environment = {
        CLUTTER_BACKEND = "wayland";
        DISPLAY = ":0";
        GDK_BACKEND = "wayland,x11";
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        SDL_VIDEODRIVER = "wayland";
      };

      layout = {
        default-column-width.proportion = 0.5;
        background-color = "transparent";
        always-center-single-column = true;
        focus-ring = {
          enable = true;
          width = 1;
          active.color = "#5BCEFA";
        };
        border = {
          enable = true;
          width = 2;
          inactive.color = "#F5A9B8";
          active.color = "#5BCEFA";
        };
      };

      cursor = {
        hide-when-typing = true;
      };

      input = {
        touchpad = {
          tap = true;
          dwt = true;
          dwtp = false;
          drag = true;
          click-method = "button-areas";
          natural-scroll = true;
          scroll-method = "two-finger";
          tap-button-map = "left-right-middle";
          accel-profile = "adaptive";
        };
      };
      gestures = {
        hot-corners.enable = true;
      };

    };
  };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      indicator-radius = 365;
      font-size = 120;
      indicator-idle-visible = false;

      # Theme: https://github.com/catppuccin/swaylock
      # https://github.com/catppuccin/swaylock/blob/main/themes/mocha.conf
      color = "1e1e2e";
      bs-hl-color = "f5e0dc";
      caps-lock-bs-hl-color = "f5e0dc";
      caps-lock-key-hl-color = "a6e3a1";
      inside-color = "00000000";
      inside-clear-color = "00000000";
      inside-caps-lock-color = "00000000";
      inside-ver-color = "00000000";
      inside-wrong-color = "00000000";
      key-hl-color = "a6e3a1";
      layout-bg-color = "00000000";
      layout-border-color = "00000000";
      layout-text-color = "cdd6f4";
      line-color = "00000000";
      line-clear-color = "00000000";
      line-caps-lock-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";
      ring-color = "b4befe";
      ring-clear-color = "f5e0dc";
      ring-caps-lock-color = "fab387";
      ring-ver-color = "89b4fa";
      ring-wrong-color = "eba0ac";
      separator-color = "00000000";
      text-color = "cdd6f4";
      text-clear-color = "f5e0dc";
      text-caps-lock-color = "fab387";
      text-ver-color = "89b4fa";
      text-wrong-color = "eba0ac";
    };
  };

  services.swayidle =
    let
      swaylock = "${lib.getExe pkgs.swaylock-effects} -f --clock --indicator";
      suspend = "${pkgs.systemd}/bin/systemctl suspend";
    in
    {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = swaylock;
        }
        {
          event = "lock";
          command = swaylock;
        }
      ];
      timeouts = [
        {
          timeout = 200;
          command = swaylock;
        }
        {
          timeout = 300;
          command = suspend;
        }
      ];
    };


  home.packages = with pkgs; [
    libnotify
    wl-clipboard
    brightnessctl
    swaybg
    xwayland-satellite
    wl-clip-persist
    mako
    nautilus
    nautilus-open-any-terminal
  ];
}
