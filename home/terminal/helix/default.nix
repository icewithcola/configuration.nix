{ config, pkgs, ... }:
{
  programs.helix = {
    enable = true;
    extraConfig = builtins.readFile ./config.toml;
    extraPackages = with pkgs; [
      jdt-language-server
      kotlin-language-server
      nixfmt
      nil
    ];
  };
}
