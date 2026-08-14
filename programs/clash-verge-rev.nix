{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.kagura.clashVergeRev.enable = lib.mkEnableOption "Clash Verge Rev";

  config = lib.mkIf config.kagura.clashVergeRev.enable {
    environment.systemPackages = [ pkgs.clash-verge-rev ];

    security.wrappers = builtins.listToAttrs (
      map (exe: {
        name = exe;
        value = {
          owner = "root";
          group = "root";
          capabilities = "cap_net_bind_service,cap_net_raw,cap_net_admin=+ep";
          source = "${pkgs.clash-verge-rev}/bin/${exe}";
        };
      }) (lib.attrNames (builtins.readDir "${pkgs.clash-verge-rev}/bin"))
    );
  };
}
