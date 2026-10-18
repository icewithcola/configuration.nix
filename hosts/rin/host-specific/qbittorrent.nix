{ pkgs, ... }:
{
  config.services.qbittorrent = {
    enable = true;
    package = pkgs.qbittorrent-enhanced-nox;
    webuiPort = 41654;
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        General.Locale = "zh_CN";
        WebUI = {
          Username = "kagura";
          Password_PBKDF2 = "sSkoxAleUAPfx19a2sH7CA==:+DsnF+AxFuWdfaX+T2nBYFGbmnibM4LbG4tPKaiZy2+tLcJPsf09Rf0m9ykDfrbpcl5X7W4VyFq8+02rpa/YTw==";
        };
      };

      BitTorrent.Session = {
        Interface = "br-cm";
        InterfaceName = "br-cm";
        ShareLimitAction = "Stop";
      };
    };
  };

  config.systemd.services.qbittorrent.serviceConfig = {
    # Bound memory leaks and restart the whole service after an OOM kill.
    MemoryMax = "4G";
    OOMPolicy = "kill";
    Restart = "on-failure";
    RestartSec = "5s";
  };
}
