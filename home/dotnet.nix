{ pkgs-unstable, ... }:

{
  home.packages = [
    pkgs-unstable.dotnet-sdk_10
    pkgs-unstable.azure-artifacts-credprovider
  ];

  home.sessionPath = [
    "$HOME/.dotnet/tools"
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${pkgs-unstable.dotnet-sdk_10}/share/dotnet";
    NUGET_PLUGIN_PATHS = "${pkgs-unstable.azure-artifacts-credprovider}/lib/azure-artifacts-credprovider/CredentialProvider.Microsoft.dll";
  };
}
