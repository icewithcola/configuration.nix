{
  lib,
  pkgs,
  ...
}:
let
  xiaomiHome = pkgs.home-assistant-custom-components.xiaomi_home;
  homeAssistantBackendHost = "127.0.0.1";
  homeAssistantBackendPort = 18123;
  httpStorage = pkgs.writeText "home-assistant-http-storage.json" (
    builtins.toJSON {
      version = 2;
      minor_version = 2;
      key = "http";
      data = {
        stable = {
          server_host = [ homeAssistantBackendHost ];
          server_port = homeAssistantBackendPort;
          cors_allowed_origins = [ "https://cast.home-assistant.io" ];
          use_x_forwarded_for = true;
          trusted_proxies = [ "127.0.0.1/32" ];
          login_attempts_threshold = -1;
          ip_ban_enabled = true;
          ssl_profile = "modern";
          use_x_frame_options = true;
          created_at = "1970-01-01T00:00:00+00:00";
          error = null;
          error_message = null;
        };
        pending = null;
        yaml_migration_done = true;
      };
    }
  );
in
{
  services.home-assistant = {
    enable = true;
    customComponents = [ xiaomiHome ];
    extraComponents = [
      "ffmpeg"
      "google_translate"
      "upnp"
      "zeroconf"
    ];
    config = {
      default_config = { };
      homeassistant.internal_url = "https://ha.home.lolicon.cyou";

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

  # Home Assistant 2026.8 migrates `http` from YAML once, then ignores YAML
  # on subsequent starts. Keep the loopback listener declarative by replacing
  # that integration's private storage record before Home Assistant starts.
  systemd.services.home-assistant = {
    preStart = lib.mkAfter ''
      ${lib.getExe' pkgs.coreutils "install"} -Dm600 ${httpStorage} /var/lib/hass/.storage/http
    '';
    restartTriggers = [ httpStorage ];
  };
}
