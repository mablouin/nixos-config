{ pkgs, pkgs-unstable, ... }:

{
  home.packages = (with pkgs; [
    azure-cli
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
