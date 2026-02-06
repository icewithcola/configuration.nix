{
  description = "Kagura's NixOS config, for x86_64-linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager-nixos = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kagura-pkgs = {
      url = "github:icewithcola/nix-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager-nixos,
      niri,
      agenix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;

      allHosts = builtins.attrNames (lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./hosts));
    in
    {
      nixosConfigurations = lib.genAttrs allHosts (
        host:
        nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = {
            inherit system inputs;
            pkgs-stable = import nixpkgs-stable {
              inherit system;
              config.allowUnfree = true;
            };
            host = "${host}";
          };

          modules = ([
            ({
              nixpkgs.overlays = [
                (final: prev: {
                  kagura-pkgs = inputs.kagura-pkgs.packages.${prev.system};
                })
              ];
            })

            agenix.nixosModules.default

            ./common.nix
            ./secrets
            ./nixosOptions
            ./services

            ./hosts/${host}
          ])
          ++ (
            let
              homeConfig = ./hosts/${host}/home.nix;
            in
            if nixpkgs.lib.pathExists homeConfig then
              [
                home-manager-nixos.nixosModules.home-manager
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.users.kagura = import homeConfig {
                    inherit
                      system
                      pkgs
                      host
                      lib
                      ;
                  };
                  home-manager.backupFileExtension = "backup";
                }
              ]
            else
              [ ]
          );
        }
      );

      formatter.${system} = pkgs.nixfmt-tree;

      # For MacOS for work
      formatter."aarch64-darwin" = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
    };
}
