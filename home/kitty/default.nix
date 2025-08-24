{
  config,
  pkgs,
  ...
}:
{
  programs.kitty = {
    enable = true;
    font = {
      package = pkgs.hack-font;
      name = "Hack";
    };
    extraConfig = builtins.readFile ./kitty.conf;
  };
}
