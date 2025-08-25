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

      environment = {
        CLUTTER_BACKEND = "wayland";
        DISPLAY = null;
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
          width = 2;
          active.color = "#5BCEFA";
          urgent.color = "#F5A9B8";
        };
        border = {
          enable = false;
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

  home.packages = with pkgs; [
    libnotify
    wl-clipboard
    brillo
    swaybg
    wl-clip-persist
    nautilus
    nautilus-open-any-terminal
  ];
}
