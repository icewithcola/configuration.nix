{
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.kagura.home.pkgSets = {
    gui = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Generic GUI packages for home-manager, like media and ide tools.
      '';
    };

    network = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Network tools for home-manager
      '';
    };

    dev = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Usage of this computer, if true, enable some development packages
        These are impacted:
        - Packages for systems
        - LSP for helix
      '';
    };
  };
}
