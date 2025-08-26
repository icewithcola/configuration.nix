let
  windowRules = [
    {
      geometry-corner-radius =
        let
          radius = 8.0;
        in
        {
          bottom-left = radius;
          bottom-right = radius;
          top-left = radius;
          top-right = radius;
        };
      clip-to-geometry = true;
      draw-border-with-background = false;
    }
    {
      matches = [
        { is-floating = true; }
      ];
      shadow.enable = true;
    }
    {
      matches = [
        {
          is-window-cast-target = true;
        }
      ];
    }
    {
      matches = [ { app-id = "org.telegram.desktop"; } ];
      block-out-from = "screencast";
    }
    {
      matches = [
        { app-id = "chromium-browser"; }
      ];
      scroll-factor = 0.5;
    }
    {
      matches = [
        { app-id = "chromium-browser"; }
      ];
      open-maximized = true;
    }
    {
      matches = [
        { title = "Picture in picture"; }
        { title = "Bitwarden"; }
        { app-id = "org.kde.polkit-kde-authentication-agent-1"; }
      ];
      open-floating = true;
      default-floating-position = {
        x = 32;
        y = 32;
        relative-to = "bottom-right";
      };
    }
  ];
in
{
  programs.niri.settings = {
    window-rules = windowRules;
  };
}
