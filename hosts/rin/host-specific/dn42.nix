{ config, ... }:
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
            HostName = "hgt0ae5n23e.sn.mynetname.net";
            Port = "22323";
            MyIP = "fdd2:4372:796f:fff0::2323:1/127";
            PeerIP = "fdd2:4372:796f:fff0::2323:0/127";
          };
        };
      };
    };
  };

}
