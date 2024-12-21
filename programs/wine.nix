{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
      wineWowPackages.stable
      wineWowPackages.waylandFull
      wine64
      winetricks
  ];
}
