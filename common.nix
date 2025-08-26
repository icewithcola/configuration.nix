{
  lib,
  pkgs,
  host,
  config,
  system,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    zsh
    helix
    wget
    curl
    git
    age
    coreutils
    usbutils
    pciutils
  ];

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    extraOptions = ''
      !include ${config.age.secrets.github-token.path}
    '';

    # Nix GC Configuration
    gc = {
      automatic = true;
      dates = "weekly";
      options = "-d";
    };
  };
}
