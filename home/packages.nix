{ pkgs, pkgs-unstable, ... }:

{
  home.packages = (with pkgs; [
    azure-cli
    go
    istioctl
    jq
    k3d
    kubectl
    kubelogin
    kubernetes-helm
    powershell
    qemu
    terraform
    yq
  ]) ++ (with pkgs-unstable; [
    nodejs_24
    pre-commit
    talosctl
    yarn-berry
  ]);
}
