{ config, lib, pkgs, ... }:

{
  wsl.enable = true;
  wsl.defaultUser = "nixos";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    home-manager
    git
    zsh
  ];

  environment.shells = with pkgs; [ zsh ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    shellAliases = {
      nixos-switch = "(cd ~/.nixos-config && git add -f user-config/*.user.nix && trap 'git reset user-config/*.user.nix' EXIT && sudo nixos-rebuild switch --flake .#nixos --option warn-dirty false)";
      home-switch = "(cd ~/.nixos-config && git add -f user-config/*.user.nix && trap 'git reset user-config/*.user.nix' EXIT && home-manager switch --flake .#nixos -b backup --option warn-dirty false)";
    };
  };

  # Enable vscode to connect to WSL
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  system.stateVersion = "24.11";
}
