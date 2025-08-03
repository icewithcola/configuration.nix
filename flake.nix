{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    kaguraRepo = {
      url = "github:icewithcola/nix-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixpkgs-unstable,
    ...
  }: {
    nixosConfigurations.kagura-notebook = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";

      specialArgs = {
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      
      modules = [
        ({
          nixpkgs.overlays = [            (final: prev: {
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
  };
}

