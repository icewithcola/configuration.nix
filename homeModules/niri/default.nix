# 感谢
# https://github.com/linuxmobile/kaku/blob/niri/home/software/wayland/niri/
# https://github.com/AsterisMono/flake/blob/main/homeModules/niri/package.nix
{ pkgs, lib, ... }:
{
  imports = [
    ./binds.nix
    ./settings.nix
    ./rules.nix
  ];

  systemd.user.services =
    let
      wallpaper = ../../home/assets/background/115688363_p1.png;
    in
    {
      swaybg = {
        Unit = {
          Description = "swaybg - show wallpaper";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          Requisite = [ "graphical-session.target" ];
        };
        Service =
          let
            show = pkgs.writeShellApplication {
              name = "swaybg-show-wallpaper";

              text = ''
                ${lib.getExe pkgs.swaybg} -i "${wallpaper}" -m fill
              '';
            };
          in
          {
            ExecStart = lib.getExe show;
            Restart = "on-failure";
          };
        Install.WantedBy = [ "graphical-session.target" ];
      };
      waybar = {
        Unit = {
          Description = "waybar - show the bar";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          Requisite = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = lib.getExe pkgs.waybar;
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
