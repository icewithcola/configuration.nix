{
  config,
  ...
}:
{
  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 53 ];
  };
}
