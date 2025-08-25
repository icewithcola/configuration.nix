{
  description = "Kagura's NixOS config, for x86_64-linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager-nixos = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

          modules = [
            ({
              nixpkgs.overlays = [
                (final: prev: {
                  kagura-pkgs = inputs.kagura-pkgs.packages.${prev.system};
                })
              ];
            })

            home-manager-nixos.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.kagura = import ./hosts/${host}/home.nix {
                inherit
                  system
                  pkgs
                  host
                  lib
                  ;
              };
              home-manager.backupFileExtension = "backup";
            }

            ./programs
            ./services
            ./hosts/${host}
          ];
        }
      );

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
