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

      # Remote controls
      "remote.nas" = {
        host = "remote.nas";
        hostname = "ssh.git.kagurach.uk";
        port = 30072;
        user = "root";
      };

      # Nekohouse Local servers
      "j1900.nekohouse" = {
        host = "j1900.nekohouse";
        hostname = "192.168.114.1";
        port = 22;
        user = "root";
      };
      "router.nekohouse" = {
        host = "router.nekohouse";
        hostname = "192.168.10.1";
        port = 22;
        user = "root";
      };
      "nas.nekohouse" = {
        host = "nas.nekohouse";
        hostname = "192.168.10.149";
        port = 22;
        user = "root";
      };

      # Nekohouse IPv6 servers
      "home.kagura.lolicon.cyou" = {
        host = "home.kagura.lolicon.cyou";
        hostname = "home.kagura.lolicon.cyou";
        port = 22;
        user = "root";
      };
      "rin.home.lolicon.cyou" = {
        host = "rin.home.lolicon.cyou";
        hostname = "rin.home.lolicon.cyou";
        port = 22;
        user = "kagura";
      };
    };
  };
}
