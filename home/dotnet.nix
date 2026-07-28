{ pkgs-dotnet, ... }:

{
  home.packages = [
    pkgs-dotnet.dotnet-sdk_10
    pkgs-dotnet.azure-artifacts-credprovider
  ];

  home.sessionPath = [
    "$HOME/.dotnet/tools"
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${pkgs-dotnet.dotnet-sdk_10}/share/dotnet";
    NUGET_PLUGIN_PATHS = "${pkgs-dotnet.azure-artifacts-credprovider}/lib/azure-artifacts-credprovider/CredentialProvider.Microsoft.dll";
  };
}
