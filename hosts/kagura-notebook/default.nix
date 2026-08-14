{
  config,
  ...
}:
{
  imports = [
    ./configuration.nix
    ./host-specific
  ];

  kagura = {
    bluetooth.enable = true;
    docker.enable = true;
    fcitx5.enable = true;
    incus.enable = true;
    niri.enable = true;
    nixLd.enable = true;
    rootFileSystem = "btrfs";
    hostname = "kagura-notebook";
    sound.enable = true;
    steam.enable = true;
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
