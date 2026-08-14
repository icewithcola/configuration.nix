{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.kagura.fcitx5.enable = lib.mkEnableOption "Fcitx 5 input method support";

  config = lib.mkIf config.kagura.fcitx5.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-gtk
          kdePackages.fcitx5-chinese-addons
          fcitx5-nord
        ];
        quickPhrase = {
          ciallo = "Ciallo～(∠・ω< )⌒☆";
        };
      };
    };
  };
}
