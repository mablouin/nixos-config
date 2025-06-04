{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            nixos-wsl.nixosModules.wsl
          ];
        };
      };

      homeConfigurations = {
        nixos = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
        };
      };

      packages.${system} = {
        default = self.packages.${system}.install;
        install = pkgs.writeShellApplication {
            name = "install";
            runtimeInputs = with pkgs; [ git ];
            text = ''${./install.sh} "$@"'';
          };
      };

      apps.${system} = {
        default = self.apps.${system}.install;
        install = {
          type = "app";
          program = "${self.packages.${system}.install}/bin/install";
        };
      };
    };
}
