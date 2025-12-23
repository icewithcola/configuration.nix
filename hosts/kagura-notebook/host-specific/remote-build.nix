{
  config,
  ...
}:
{
  nix = {
    buildMachines = [
      {
        hostName = "kagura@rin.home.lolicon.cyou";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 3;
        speedFactor = 2;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
        mandatoryFeatures = [ ];
      }
    ];

    distributedBuilds = true;
    settings = {
      builders-use-substitutes = true;
    };
  };
}
