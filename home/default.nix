{
  pkgs,
  host,
  config,
  ...
}:
let 
    inherit (lib) mkOption types;
in 
{
  options.kagura.home = {
    targets = mkOption {
      type = types.enum ["headless", "gui"];
      default = ["gui"];
      description = "List of home targets to install. Values = ['headless', 'gui']";
    };

    targets.gui.dev = mkOption {
      type = types.bool;
      default = true;
      description = "Usage of this computer, if true, enable some development packages";
    };
  };

  imports = ([
    ./home-file.nix
    ./packages.nix
    ./kitty
    ./terminal
  ]) ++ (lib.mkIf config.kagura.home.targets == "gui" [  ]);

  programs.home-manager.enable = true;

  home = {
    sessionVariables = {
      EDITOR = "hx";

      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

      INPUT_METHOD = "fcitx";
      QT_IM_MODULE = "fcitx";
      GTK_IM_MODULE = "fcitx";
      XIM_SERVERS = "fcitx";
    };

    username = "kagura";
    homeDirectory = "/home/kagura";
    stateVersion = "24.11";
  };

}
