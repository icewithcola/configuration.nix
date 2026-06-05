{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mkIf
    ;

  cfg = config.kagura.virt;
in
{
  options.kagura.virt = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable virtualization features, this option enables libvirtd(virsh). For virt-manager, you need to enable `kagura.virt.virtManager`";
    };

    virtManager = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable virt-manager, a GUI tool for managing virtual machines.
        This option depends on `kagura.virt.enable` and will enable it if not already enabled.
      '';
    };
  };

  config = mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = cfg.virtManager;
  };
}
