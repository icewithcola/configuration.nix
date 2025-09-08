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
      ];
      default = [ "gui" ];
      description = "List of home targets to install. Values = ['headless', 'gui']";
    };

    dev = mkOption {
      type = types.bool;
      default = true;
      description = "Usage of this computer, if true, enable some development packages";
    };
  };
}
