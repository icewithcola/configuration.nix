{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.kagura = {
    useFullFonts = mkOption {
      type = types.bool;
      description = "Whether to use full fonts, have CJK + emoji + mono, use on a GUI system";
      default = false;
    };
  };

  config.fonts = lib.mkIf config.kagura.useFullFonts {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      meslo-lgs-nf
      kagura-pkgs.HarmonyOS-Sans-fonts
      kagura-pkgs.noto-fonts-cjk-sans-static
    ];
    fontconfig.defaultFonts = {
      serif = [
        "Noto Serif"
        "Noto Serif CJK SC"
        "Noto Color Emoji"
      ];

      sansSerif = [
        "Noto Sans"
        "Noto Sans CJK SC"
        "Noto Color Emoji"
      ];

      emoji = [
        "Noto Color Emoji"
      ];
    };
  };
}
