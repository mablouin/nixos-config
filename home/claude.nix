{ config, pkgs, lib, ... }:

let
  # Script to add home directory to trusted projects in ~/.claude.json
  trustHomeDirectory = pkgs.writeShellScript "trust-home-directory" ''
    CLAUDE_JSON="$HOME/.claude.json"
    HOME_DIR="${config.home.homeDirectory}"

    # Create .claude.json if it doesn't exist
    if [ ! -f "$CLAUDE_JSON" ]; then
      echo '{"projects":{}}' > "$CLAUDE_JSON"
    fi

    # Use jq to add/update the trust setting for home directory
    ${pkgs.jq}/bin/jq --arg homedir "$HOME_DIR" \
      '.projects[$homedir].hasTrustDialogAccepted = true' \
      "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp" && \
      mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
  '';
in
{
  # Configure Claude Code settings
  home.file.".claude/settings.json" = {
    text = builtins.toJSON {
      permissions = {
        additionalDirectories = [
          config.home.homeDirectory
        ];
      };
    };
  };

  # Add activation script to trust home directory
  home.activation.trustClaudeHomeDirectory = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD ${trustHomeDirectory}
  '';
}
