{
  config,
  ...
}:
{
  imports = [
    ./configuration.nix
    ./host-specific
    ../../nixosModules/niri
    ../../programs/fcitx5.nix
    ../../programs/nix-ld.nix
    ../../programs/steam.nix
    ../../programs/incus.nix
    ../../services/bluetooth.nix
    ../../services/sound.nix
    ../../services/docker.nix
  ];

  kagura = {
    rootFileSystem = "btrfs";
    hostname = "kagura-notebook";
    useFullFonts = true;

    tailscale = {
      enable = true;
      tailnetName = "dace-teeth";
      authKeyFile = config.age.secrets.tailscale-kagura-notebook.path;
    };

    virt = {
      enable = true;
      virtManager = true;
    };
  };
}
