{ config, pkgs, pkgs-unstable, lib, ... }:

let
  collectNixFilesRecursive = dir:
    let
      entries = builtins.readDir dir;
      process = name: type:
        if type == "directory" then
          collectNixFilesRecursive (dir + "/${name}")
        else if (builtins.match ".*\\.nix$" name) != null then
          [ (dir + "/${name}") ]
        else
          [];
    in
    lib.concatLists (lib.mapAttrsToList process entries);
in
{
  imports = collectNixFilesRecursive ./home;

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
