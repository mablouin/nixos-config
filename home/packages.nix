{ pkgs, pkgs-unstable, ... }:

{
  home.packages = [
    pkgs.azure-cli
    pkgs.go
    pkgs.istioctl
    pkgs.jq
    pkgs.k3d
    pkgs.kubectl
    pkgs.kubelogin
    pkgs.kubernetes-helm
    pkgs.powershell
    pkgs.qemu
    pkgs.terraform
    pkgs.yq

    pkgs-unstable.nodejs_24
    pkgs-unstable.pre-commit
    pkgs-unstable.talosctl
    pkgs-unstable.yarn-berry
  ];
}
