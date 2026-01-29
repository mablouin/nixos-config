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
├── home.nix               # User-level home-manager configuration
├── install.sh             # Bootstrap script run by `nix run`
└── user-config/           # User-specific configs (gitignored)
    ├── home.user.nix.example   # Template for username/home directory
    ├── git.user.nix.example    # Template for git identity
    ├── home.user.nix           # Created at install (gitignored)
    └── git.user.nix            # Created at install (gitignored)
```

## Key Concepts

### Standalone Home-Manager

Home-manager is NOT integrated into NixOS modules. This means:

- `sudo nixos-rebuild switch` applies system config only
- `home-manager switch` applies user config only
- Two separate commands, but allows home.nix to be portable to non-NixOS systems

### User Config Files (*.user.nix)

Sensitive/personal data is kept in `user-config/*.user.nix` files which are:

- Gitignored to prevent committing personal info
- Created from `.example` templates during install
- Auto-imported by `home.nix` using `builtins.readDir`

**Important**: Nix flakes only see git-tracked files. The aliases stage these files temporarily during builds, then unstage them.

### Aliases

Defined in `configuration.nix` under `programs.zsh.shellAliases`:

- `nixos-switch` - Rebuild system config (stages user files, builds, unstages)
- `home-switch` - Rebuild home-manager config (stages user files, builds, unstages)

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

Edit `home.nix`:

```nix
home.packages = with pkgs; [
  your-package-here
];
```

### Adding a new user config file

1. Create `user-config/something.user.nix.example` with template content
2. The file will be auto-imported by `home.nix` once `something.user.nix` exists
3. Update `install.sh` if special handling is needed

### Configuring programs via home-manager

Edit `home.nix` to add program configurations:

```nix
programs.zsh = {
  enable = true;
  # Add zsh configuration here
};
```

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
