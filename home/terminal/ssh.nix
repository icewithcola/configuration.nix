{ config, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
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
        hostname = "192.168.10.149";
        port = 22;
        user = "root";
      };
      "v6.home.lan" = {
        host = "v6.home.lan";
        hostname = "home.kagura.lolicon.cyou";
        port = 22;
        user = "root";
      };
    };
  };
}
