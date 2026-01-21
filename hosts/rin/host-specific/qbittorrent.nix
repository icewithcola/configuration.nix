{
  pkgs,
  config,
  ...
}: {
  config.services.qbittorrent = {
    enable = true;
    package = pkgs.qbittorrent-enhanced-nox;
    webuiPort = 41654;

  };
}