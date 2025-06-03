#!/bin/sh

CONFIG_DIR=~/.nixos-config

# Clone config repo
nix-shell -p git --command "git clone https://github.com/mablouin/nixos-config $CONFIG_DIR"

# Rebuild system
sudo nixos-rebuild switch --flake $CONFIG_DIR --no-write-lock-file;

echo "flake installed"
