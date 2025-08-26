{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.clash-verge-rev ];

  security.wrappers = builtins.listToAttrs (
    map (exe: {
      name = exe;
      value = {
        owner = "root";
        group = "root";
        capabilities = "cap_net_bind_service,cap_net_admin=+ep";
        source = "${pkgs.clash-verge-rev}/bin/${exe}";
      };
    }) (lib.attrNames (builtins.readDir "${pkgs.clash-verge-rev}/bin"))
  );
}
