{
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.kagura.home = {
    type = mkOption {
      type = types.enum [
        "headless"
        "gui"
        "minimal"
      ];
      default = [ "gui" ];
      description = ''
        List of home targets to install. Values = ['headless', 'gui', 'minimal']
        - gui: full GUI packages, for PC & laptop
        - headless: headless packages, for server, but with a lot of useful tools
        - minimal: minimal packages, for server, without tools
        ''
      ;
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
