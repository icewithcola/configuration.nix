{ lib, config, ... }:
{
  services.frp = {
    enable = true;
    role = "client";
    settings = {
      serverAddr = "ssh.git.kagurach.uk";
      serverPort = 30071;

      auth.token = builtins.readFile config.age.secrets.frp-token.file;
      proxies = [
        {
          name = "web";
          type = "http";
          localIP = "127.0.0.1";
          localPort = 45323;
          customDomains = [ "al.lolicon.cyou" ];
        }
        {
          name = "ssh";
          type = "tcp";
          localIP = "127.0.0.1";
          localPort = 22;
          remotePort = 30072;
        }
      ];
    };
  };
}
