# NixOS Configuration

## Fresh Install

On a fresh NixOS WSL install, run:

```bash
nix run --experimental-features 'nix-command flakes' github:mablouin/nixos-config
```

This will:

1. Clone this repo to `~/.nixos-config`
2. Create `*.user.nix` files from templates
3. Apply the NixOS system configuration
4. Apply home-manager user configuration

## After Installation

Edit the user config files with your details:

- `~/.nixos-config/git.user.nix` - Your git name and email

Then rebuild:

```bash
home-manager switch --flake ~/.nixos-config#nixos
```

## Making Changes

For system changes (packages in `configuration.nix`):

```bash
sudo nixos-rebuild switch --flake ~/.nixos-config#nixos
```

For user changes (packages/dotfiles in `home.nix`):

```bash
home-manager switch --flake ~/.nixos-config#nixos
```
