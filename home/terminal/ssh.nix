{ config, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
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
      "remote.dorm.lan" = {
        host = "remote.dorm.lan";
        hostname = "ssh.git.kagurach.uk";
        port = 30072;
        user = "root";
      };
      "router.dorm.lan" = {
        host = "router.dorm.lan";
        hostname = "192.168.10.1";
        port = 22;
        user = "11451";
      };
      "nas.dorm.lan" = {
        host = "nas.dorm.lan";
        hostname = "192.168.10.150";
        port = 22;
        user = "root";
      };
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
