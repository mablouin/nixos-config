{ config, pkgs, lib, ... }:

{
  home.packages = [
    pkgs.dotnet-sdk_10
    pkgs.azure-artifacts-credprovider
  ];

  home.sessionPath = [
    "$HOME/.dotnet/tools"
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_10}/share/dotnet";
    NUGET_PLUGIN_PATHS = "${pkgs.azure-artifacts-credprovider}/lib/azure-artifacts-credprovider/CredentialProvider.Microsoft.dll";
  };
}
