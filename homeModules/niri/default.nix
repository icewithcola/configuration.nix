# 感谢
# https://github.com/linuxmobile/kaku/blob/niri/home/software/wayland/niri/
# https://github.com/AsterisMono/flake/blob/main/homeModules/niri/package.nix
{
  imports = [
    ./binds.nix
    ./settings.nix
    ./rules.nix
  ];
}
