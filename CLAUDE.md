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

## Homebrew (home/homebrew.nix)

Homebrew runs inside a `buildFHSEnv` bubblewrap sandbox that provides a standard Linux filesystem layout (`/lib64/ld-linux-x86-64.so.2`, etc.), since NixOS lacks FHS paths natively.

### Configuration

Taps and formulas are declared in `home/user-config/homebrew.user.nix` (gitignored):

- `homebrew.taps` — attrset of `"owner/tap-name" = "git-url"`
- `homebrew.brews` — list of formula names (e.g., `"geneteccentral/tap/engage-cli"`)

### Commands

- `brew` — runs brew inside FHS env
- `brew-run <cmd> [args]` — runs any command inside FHS env
- `brew-shell` — interactive bash inside FHS env

### How binaries are exposed

Brew-installed binaries are dynamically linked and won't run on NixOS directly. The module auto-generates shell aliases at shell init:

1. Extracts formula base names from `homebrew.brews` (e.g., `"geneteccentral/tap/engage-cli"` → `"engage-cli"`)
2. Scans `/home/linuxbrew/.linuxbrew/Cellar/<formula>/*/bin/*` for executables
3. Creates aliases like `alias engage="brew-run engage"` routing through the FHS env

No separate binary declaration needed — adding a formula to `brews` automatically exposes its binaries.

### Activation (on home-switch)

1. Creates `/home/linuxbrew/.linuxbrew` via sudo (outside FHS env, since sudo fails inside bwrap)
2. Installs Homebrew if not present
3. Pre-installs azure-devops az CLI extension
4. Generates a Brewfile from declared taps/brews and runs `brew bundle`

### Host tool access (brew-run)

`brew-run` bind-mounts the host `/usr/bin` into `/host-usr-bin` inside the sandbox and prepends it to `PATH`. This makes WSL-injected tools (Docker, docker-compose, etc.) available to brew-installed CLIs without adding them to `targetPkgs`.

### WSL .exe interop limitation

WSL routes Windows `.exe` execution through `/init` via binfmt_misc, but `buildFHSEnv` replaces `/init` with its own startup script. This is a fundamental conflict — `.exe` binaries cannot run inside the bwrap sandbox. The `/init` symlink cannot be overridden with `--ro-bind` in `extraBwrapArgs` (it follows the symlink to the read-only nix store).

**Docker workaround:** `brew-run` sets `DOCKER_CONFIG=~/.docker-fhs` with a copy of `~/.docker/config.json` that has `credsStore` removed. Docker stores credentials directly in the config file instead of calling `docker-credential-desktop.exe`. ACR tokens from `az acr login` are temporary, so plaintext storage is acceptable.

### Gotchas

- sudo cannot run inside the bwrap sandbox ("no new privileges") — do it in the activation script
- Nix store files are read-only — Brewfile is copied with `install -m 644`
- `icu` is required in `targetPkgs` for ArtifactTool (used by engage-cli's download strategy)
- Homebrew state persists at `/home/linuxbrew/.linuxbrew` across home-switch runs
- To upgrade formulas, run `brew upgrade`

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
