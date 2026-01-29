{ config, pkgs, pkgs-unstable, lib, ... }:

let
  userConfigDir = ./user-config;
  files = builtins.attrNames (builtins.readDir userConfigDir);
  userFiles = builtins.filter (name: (builtins.match ".*\\.user\\.nix$" name) != null) files;
in
{
  imports = [
    ./home/zsh.nix
    ./home/claude.nix
  ] ++ map (name: userConfigDir + "/${name}") userFiles;

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.powershell

    pkgs-unstable.claude-code
  ];
}
