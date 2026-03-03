{ config, pkgs, lib, ... }:

{
  home.packages = [
    pkgs.dotnet-sdk_10
  ];

  home.sessionPath = [
    "$HOME/.dotnet/tools"
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_10}/share/dotnet";
  };
}
