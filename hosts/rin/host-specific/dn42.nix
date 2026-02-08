{ config, pkgs, ... }:
{
  kagura.dn42 = {
    enable = true;
    asn = 4242422323;
    routerIp = "fdcb:dded:cbcc::1";
    routerId = "192.168.149.167";
    subnet = "fdcb:dded:cbcc::/48";

    wireguard.PrivateKey = config.age.secrets.wireguard-dn42.path;

    peers = {
      "cryolitia" = {
        asn = 4242420994;
        wireguard = {
          PublicKey = "IGgMsGR/mzAMYj6VNivzDyk+x4iJf5HcXMACmX846XU=";
          EndPoint = {
            HostName = "cryolitia.loli.it.eu.org";
            Port = "22323";
            MyIP = "fdd2:4372:796f:fff0::2323:1/127";
            PeerIP = "fdd2:4372:796f:fff0::2323:0/127";
          };
        };
      };
    };
  };

  systemd.services."dn42-static" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.iproute2}/bin/ip -6 addr add fdcb:dded:cbcc::1/64 dev enx2c534a1227e8";
    };
  };
}
