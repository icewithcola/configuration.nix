{
  pkgs,
  config,
  lib,
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
    settings = {
      trusted-users = [ "kagura" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    extraOptions = lib.optionalString (config.age.secrets ? github-token) ''
      !include ${config.age.secrets.github-token.path}
    '';

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
