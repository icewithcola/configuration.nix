{
  pkgs,
  lib,
  config,
  ...
}:
{
  programs.niri.binds =
    with config.lib.niri.actions;
    let
      sh = spawn "sh" "-c";
      set-volume = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@";
      brillo = spawn "${pkgs.brillo}/bin/brillo" "-q" "-u" "300000";

    in
    {
      "Mod+R".action = spawn "fuzzel";
      "Mod+Q".action = spawn "kitty";

      # Fn
      "XF86MonBrightnessDown".action = brillo "-U" "5";
      "XF86MonBrightnessUp".action = brillo "-A" "5";

      "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
      "XF86AudioRaiseVolume".action = set-volume "5%+";
      "XF86AudioLowerVolume".action = set-volume "5%-";

      "XF86AudioMicMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
    };
}
