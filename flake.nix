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

  outputs = { self, nixpkgs, nixos-wsl, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
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

      packages.${system}.default = pkgs.writeShellApplication {
        name = "install";
        runtimeInputs = with pkgs; [ git ];
        text = builtins.readFile ./install.sh;
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/install";
      };
    };
}
