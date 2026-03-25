{ config, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      # Git services
      "github.com" = {
        host = "github.com";
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
      };
      "ssh.git.kagurach.uk" = {
        host = "ssh.git.kagurach.uk";
        hostname = "ssh.git.kagurach.uk";
        port = 22;
        user = "root";
      };

      # Servers
      "alice-jp" = {
        host = "alice-jp";
        hostname = "alice-jp.srv.kagurach.uk";
        port = 22;
        user = "root";
      };
      "emilia" = {
        host = "emilia";
        hostname = "emilia.srv.kagurach.uk";
        port = 22;
        user = "kagura";
      };

      # Local servers
      "rin.home.lolicon.cyou" = {
        host = "rin.home.lolicon.cyou";
        hostname = "rin.home.lolicon.cyou";
        port = 22;
        user = "kagura";
      };
      "stella.home.lolicon.cyou" = {
        host = "stella.home.lolicon.cyou";
        hostname = "stella.home.lolicon.cyou";
        port = 22;
        user = "root";
      };

      # Remote Controller
      "j1900.lan" = {
        host = "j1900.lan";
        hostname = "192.168.114.1";
        port = 22;
        user = "root";
      };
    };
  };
}
