{
  lib,
  pkgs,
  host,
  config,
  ...
}:
{
  imports = [
    ./options.nix
    ./home-file.nix
    ./packages.nix
    ./kitty
    ./terminal
  ];

  programs.home-manager.enable = true;

  home = {
    sessionVariables = {
      EDITOR = "hx";

      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

      INPUT_METHOD = "fcitx";
      QT_IM_MODULE = "fcitx";
      XIM_SERVERS = "fcitx";
    };

    username = "kagura";
    homeDirectory = "/home/kagura";
    stateVersion = "24.11";
  };
}
