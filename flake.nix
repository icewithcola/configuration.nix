{
  description = "Kagura's notebook's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    kaguraRepo = {
      url = "github:icewithcola/nix-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.kagura-notebook = nixpkgs.lib.nixosSystem rec {

        specialArgs = {
          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
        };

        modules = [
          ({
            nixpkgs.overlays = [
              (final: prev: {
                kaguraRepo = inputs.kaguraRepo.packages."${prev.system}";
              })
            ];
          })
          # 这里导入之前我们使用的 configuration.nix，
          # 这样旧的配置文件仍然能生效
          ./configuration.nix

          ./programs
        ];

      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;

    };
}
