{
  lib,
  config,
  host,
  ...
}:
let
  secretFiles = {
    github-token = ./github-token.age;
    ddns-token = ./ddns-token.age;
    tailscale-emilia = ./tailscale-emilia.age;
    tailscale-kagura-notebook = ./tailscale-kagura-notebook.age;
    tailscale-rin = ./tailscale-rin.age;
    wireguard-dn42 = ./wireguard-dn42.age;
  };

  hostSecrets = {
    # Emilia's identity is not a recipient of the shared secrets.
    emilia = [ "tailscale-emilia" ];
    kagura-notebook = [
      "github-token"
      "tailscale-kagura-notebook"
    ];
    rin = [
      "github-token"
      "ddns-token"
      "tailscale-rin"
      "wireguard-dn42"
    ];
  };

  secretsForHost = hostSecrets.${host} or [ ];
in
{
  age.secrets =
    lib.listToAttrs (
      map (name: {
        inherit name;
        value.file = secretFiles.${name};
      }) secretsForHost
    )
    # Only rin can decrypt both TLS files; enabling nginx is not sufficient.
    // lib.optionalAttrs (host == "rin" && config.services.nginx.enable) {
      "loli-cer" = {
        mode = "770";
        owner = "nginx";
        group = "nginx";
        file = ./loli-cer.age;
      };
      "loli-priv" = {
        mode = "770";
        owner = "nginx";
        group = "nginx";
        file = ./loli-priv.age;
      };
    };

  age.identityPaths = [
    "/home/kagura/.ssh/id_ed25519"
    "/etc/ssh/id_ed25519"
  ];
}
