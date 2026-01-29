#!/usr/bin/env bash
set -e

CONFIG_DIR=~/.nixos-config
USER_CONFIG_DIR="$CONFIG_DIR/user-config"

# Clone config repo if not exists
if [ ! -d "$CONFIG_DIR" ]; then
  nix-shell -p git --run "git clone https://github.com/mablouin/nixos-config $CONFIG_DIR"
fi

cd "$CONFIG_DIR"

# Prompt for username if home.user.nix doesn't exist
if [ ! -f "$USER_CONFIG_DIR/home.user.nix" ]; then
  read -rp "Enter your username [$(whoami)]: " username
  username="${username:-$(whoami)}"

  cat > "$USER_CONFIG_DIR/home.user.nix" << EOF
{
  home.username = "$username";
  home.homeDirectory = "/home/$username";
}
EOF
  echo "Created home.user.nix for user: $username"
fi

# Copy other template files to user files (if they don't exist)
for template in "$USER_CONFIG_DIR"/*.user.nix.example; do
  [ -f "$template" ] || continue
  target="${template%.example}"
  if [ ! -f "$target" ]; then
    cp "$template" "$target"
    echo "Created $(basename "$target") from template - please edit with your details"
  fi
done

# Rebuild system config
sudo nixos-rebuild switch --flake "$CONFIG_DIR#nixos"

# Apply home-manager config
home-manager switch --flake "$CONFIG_DIR#nixos"

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Edit user config files in $USER_CONFIG_DIR:"
echo "     - git.user.nix"
echo "  2. Re-run: home-manager switch --flake $CONFIG_DIR#nixos"
