#!/bin/sh

CONFIG_DIR=~/.config

# Clone config repo
nix-shell -p git --command "git clone https://gitlab.com/librephoenix/nixos-config $CONFIG_DIR"

# Rebuild system
sudo nixos-rebuild switch --flake $CONFIG_DIR;

echo "flake installed"
