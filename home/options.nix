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
      default = false;
      description = ''
        Enable the core development tools used for Nix and general remote work.
      '';
    };

    devJvm = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable Java and Kotlin language servers for Helix.
      '';
    };

    devAndroid = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable Android command-line development tools.
      '';
    };
  };
}
