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
    python3
    qemu
    terraform
    typescript
    unzip
    yq
  ]) ++ (with pkgs-unstable; [
    docker
    golangci-lint
    nodejs_24
    pre-commit
    rtk
    talosctl
    yarn-berry
    zarf
  ]);
}
