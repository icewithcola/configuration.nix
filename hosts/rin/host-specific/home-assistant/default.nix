{ pkgs, ... }:
let
  xiaomiHome = pkgs.home-assistant-custom-components.xiaomi_home;
  homeAssistantBackendPort = 18123;
in
{
  services.home-assistant = {
    enable = true;
    customComponents = [ xiaomiHome ];
    extraComponents = [
      "ffmpeg"
      "zeroconf"
    ];
    config = {
      default_config = { };
      homeassistant.internal_url = "https://ha.home.lolicon.cyou";

      http = {
        server_host = "127.0.0.1";
        server_port = homeAssistantBackendPort;
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" ];
      };

      lovelace.dashboards = {
        nixos-lovelace = null;
        "kaguras-home" = {
          mode = "yaml";
          filename = "/etc/home-assistant/ui-lovelace.yaml";
          title = "Kagura's home";
          icon = "mdi:home-heart";
          show_in_sidebar = true;
          require_admin = false;
        };
      };
    };

    lovelaceConfigFile = ./dashboard.yaml;
  };
}
