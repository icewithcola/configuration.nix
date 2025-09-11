{
  lib,
  inputs,
  config,
  ...
}:
let
  enableNixOSModule = (x: lib.map (s: ../../nixosModules/${s}) x);
  enablePrograms = (x: lib.map (s: ../../programs/${s}.nix) x);
  enableServices = (x: lib.map (s: ../../services/${s}.nix) x);
in
{
  imports = ([
    ./configuration.nix
  ])
  ++ (enableNixOSModule [
  ])
  ++ (enablePrograms [
    "incus"
  ])
  ++ (enableServices [
    "sshd"
    "ddns"
    "dn42"
  ]);

  kagura.ddns = {
    enable = true;
    host = "rin";
    secretFile = config.age.secrets.ddns-token.path;
    interface = "enp7s0f0";
  };
  kagura.dn42 = {
    enable = true;
    asn = 4242422323;
    routerIp = "fdcb:dded:cbcc::2";
    routerId = "192.168.10.166";
    subnet = "fdcb:dded:cbcc::/48";

    wireguard.PrivateKey = config.age.secrets.wireguard-dn42.path;

    peers = {
      "4242420833" = {
        wireguard = {
          PublicKey = "k1bNDu2fBFKCmG+YSAYuv4GGx8OM/xZycv8xaqD7uwY=";
          EndPoint = {
            HostName = "ivy.requiem.garden";
            Port = "22323";
            MyIP = "fe80:759:2323::2/64";
            PeerIP = "fe80:759:0833::1/64";
          };
        };
      };

      "4242420994" = {
        wireguard = {
          PublicKey = "IGgMsGR/mzAMYj6VNivzDyk+x4iJf5HcXMACmX846XU=";
          EndPoint = {
            HostName = "hgt0ae5n23e.sn.mynetname.net";
            Port = "22323";
            MyIP = "fdd2:4372:796f:ffff::2323:2/127";
            PeerIP = "fdd2:4372:796f:ffff::2323:0/127";
          };
        };
      };
    };
  };
}
