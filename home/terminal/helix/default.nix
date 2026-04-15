{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.helix = {
    enable = true;
    extraConfig = builtins.readFile ./config.toml;
    extraPackages =
      [ ]
      ++ (lib.optionals config.kagura.home.pkgSets.dev (
        with pkgs;
        [
          jdt-language-server
          kotlin-language-server
          nixfmt
          nil
        ]
      ));
  };
}
