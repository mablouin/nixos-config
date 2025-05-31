{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          system = system;
          modules = [ ./configuration.nix ];
        };
      };

      packages.${system}.default = pkgs.writeScriptBin "install" ''
        echo "flake installed"
      '';

      apps.${system} = {
        default = self.apps.${system}.install;
        install = {
          type = "app";
          program = "${self.packages.${system}.install}/bin/install";
        };
      };
    };
}
