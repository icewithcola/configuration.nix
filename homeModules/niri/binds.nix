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
      swaylock = "${lib.getExe pkgs.swaylock-effects} -f --clock --indicator";
      suspend = "${pkgs.systemd}/bin/systemctl suspend";
    in
    {
      "Mod+R".action = spawn "fuzzel";
      "Mod+Q".action = spawn "kitty";
      "Mod+W".action = spawn "google-chrome-stable";
      "Mod+F".action = toggle-window-floating;
      "Mod+L".action = sh swaylock;
      "Mod+Comma".action = sh "plasma-emojier";
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
      "Mod+Shift+L".action = sh suspend;
      "Mod+Shift+Minus".action = set-window-height "-10%";
      "Mod+Shift+Equal".action = set-window-height "+10%";


      "Mod+1".action = set-column-width "25%";
      "Mod+2".action = set-column-width "50%";
      "Mod+3".action = set-column-width "75%";
      "Mod+4".action = set-column-width "100%";

      # Fn
      "XF86MonBrightnessUp".action = sh "brightnessctl s +5%";
      "XF86MonBrightnessDown".action = sh "brightnessctl s 5%-";

      "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
      "XF86AudioRaiseVolume".action = set-volume "5%+";
      "XF86AudioLowerVolume".action = set-volume "5%-";

      "XF86AudioMicMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
    };
}
