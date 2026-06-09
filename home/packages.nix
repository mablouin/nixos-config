{ pkgs, pkgs-unstable, ... }:

{
  home.packages = (with pkgs; [
    (azure-cli.withExtensions [
      azure-cli.extensions.azure-devops
      azure-cli.extensions.amg
    ])
    go
    istioctl
    jdk25_headless
    jq
    k3d
    kubectl
    kubelogin
    kubernetes-helm
    powershell
    qemu
    terraform
    typescript
    unzip
    yq
  ]) ++ (with pkgs-unstable; [
    nodejs_24
    pre-commit
    talosctl
    yarn-berry
    zarf
  ]);
}
