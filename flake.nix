{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
  };

  outputs = { self, nixpkgs, nixos-wsl, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          system = system;
          modules = [
            ./configuration.nix
            nixos-wsl.nixosModules.wsl
          ];
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
