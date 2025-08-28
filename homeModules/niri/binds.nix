{
  pkgs,
  lib,
  config,
  ...
}:
{
  programs.niri.settings.binds =
    with config.lib.niri.actions;
    let
      sh = spawn "sh" "-c";
      set-volume = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@";
      brillo = spawn "${pkgs.brillo}/bin/brillo" "-q" "-u" "300000";
    in
    {
      "Mod+R".action = spawn "fuzzel";
      "Mod+Q".action = spawn "kitty";
      "Mod+W".action = spawn "google-chrome-stable";
      "Mod+F".action = toggle-window-floating;
      "Mod+L".action = sh "swaylock -f";
      "Mod+Minus".action = set-column-width "-10%";
      "Mod+Equal".action = set-column-width "+10%";
      "Mod+Left".action = focus-column-left;
      "Mod+Right".action = focus-column-right;
      "Mod+Down".action = focus-workspace-down;
      "Mod+Up".action = focus-workspace-up;

      "Mod+Shift+S".action = screenshot;
      "Mod+Shift+E".action = quit;
      "Mod+Shift+C".action = close-window;
      "Mod+Shift+F".action = expand-column-to-available-width;
      
      "Mod+1".action = set-column-width "25%";
      "Mod+2".action = set-column-width "50%";
      "Mod+3".action = set-column-width "75%";
      "Mod+4".action = set-column-width "100%";

      # Fn
      "XF86MonBrightnessDown".action = brillo "-U" "5";
      "XF86MonBrightnessUp".action = brillo "-A" "5";

      "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
      "XF86AudioRaiseVolume".action = set-volume "5%+";
      "XF86AudioLowerVolume".action = set-volume "5%-";

      "XF86AudioMicMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
    };
}
