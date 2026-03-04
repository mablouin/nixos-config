# NixOS Configuration Guide

This file documents how this NixOS WSL configuration works.

## Overview

This is a flake-based NixOS configuration for WSL with standalone home-manager. A single bootstrap command sets up the entire environment from a fresh NixOS WSL install.

## File Structure

```text
nixos-config/
├── flake.nix              # Flake definition with nixos and home-manager configs
├── flake.lock             # Pinned dependency versions
├── configuration.nix      # System-level NixOS configuration
├── home.nix               # Entry point: recursively imports all .nix files from home/
├── install.sh             # Bootstrap script run by `nix run`
└── home/                  # Modular home-manager .nix files
    └── user-config/       # Personal/sensitive *.user.nix (gitignored)
        └── *.user.nix.example  # Templates to get started
```

## Key Concepts

### Standalone Home-Manager

Home-manager is NOT integrated into NixOS modules. This means:

- `sudo nixos-rebuild switch` applies system config only
- `home-manager switch` applies user config only
- Two separate commands, but allows home.nix to be portable to non-NixOS systems

### Modular Home Configuration

`home.nix` uses `collectNixFilesRecursive` to auto-import every `.nix` file under `home/`. To add new configuration, create a new `.nix` file in `home/` and it will be picked up automatically.

The flake provides both `pkgs` (stable, nixos-25.11) and `pkgs-unstable` (nixos-unstable) as arguments to all modules.

### User Config Files (*.user.nix)

Sensitive/personal data is kept in `home/user-config/*.user.nix` files which are:

- Gitignored to prevent committing personal info
- Created from `.example` templates during install
- Auto-imported alongside all other `home/` modules via the recursive import

**Important**: Nix flakes only see git-tracked files. The aliases stage these files temporarily during builds, then unstage them.

### Aliases

Defined in `configuration.nix` under `programs.zsh.shellAliases`:

- `nixos-switch` - Rebuild system config (stages `home/user-config/*.user.nix`, builds, unstages)
- `home-switch` - Rebuild home-manager config (stages `home/user-config/*.user.nix`, builds, unstages)

These use `trap ... EXIT` to ensure files are unstaged even if the build fails.

## Adding New Configuration

### Adding a new system package

Edit `configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  git
  zsh
  your-package-here
];
```

### Adding a new user package

Edit `home/packages.nix`. Use `pkgs` for stable or `pkgs-unstable` for bleeding-edge:

```nix
home.packages = [
  pkgs.your-package-here
  pkgs-unstable.some-unstable-package
];
```

### Adding a new home-manager module

Create a new file in `home/` (e.g., `home/mytool.nix`). It will be auto-imported:

```nix
{ pkgs, ... }:

{
  programs.mytool = {
    enable = true;
  };
}
```

### Adding a new user config file

1. Create `home/user-config/something.user.nix.example` with template content
2. The file will be auto-imported once `something.user.nix` exists
3. Update `install.sh` if special handling is needed

## Bootstrap Command

From a fresh NixOS WSL install:

```bash
nix run --experimental-features 'nix-command flakes' github:mablouin/nixos-config
```

Or from a specific branch:

```bash
nix run --experimental-features 'nix-command flakes' github:mablouin/nixos-config/branch-name -- branch-name
```

## Common Tasks

### Update flake inputs

```bash
cd ~/.nixos-config
nix flake update
nixos-switch
home-switch
```

### Check what would change

```bash
cd ~/.nixos-config
nixos-rebuild dry-run --flake .#nixos
```

### Rollback

```bash
sudo nixos-rebuild switch --rollback
# or for home-manager:
home-manager generations  # list generations
home-manager switch --rollback
```
