{
  pkgs,
  config,
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

    extraOptions = ''
      !include ${config.age.secrets.github-token.path}
    '';

    gc = {
      automatic = true;
      dates = "weekly";
      options = "-d";
    };
  };
}
