{ config, pkgs, pkgs-unstable, lib, ... }:

let
  userConfigDir = ./user-config;
  userConfigFiles = builtins.attrNames (builtins.readDir userConfigDir);
  userFiles = builtins.filter (name: (builtins.match ".*\\.user\\.nix$" name) != null) userConfigFiles;

  homeDir = ./home;
  homeFiles = builtins.attrNames (builtins.readDir homeDir);
  homeNixFiles = builtins.filter (name: (builtins.match ".*\\.nix$" name) != null) homeFiles;
in
{
  imports = map (name: homeDir + "/${name}") homeNixFiles
    ++ map (name: userConfigDir + "/${name}") userFiles;

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
