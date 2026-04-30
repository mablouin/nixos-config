{ config, pkgs, pkgs-unstable, lib, ... }:

let
  settingsJson = builtins.toJSON ({
    model = "claude-opus-4-7";
    permissions = {
      additionalDirectories = [
        config.home.homeDirectory
      ];
    };
  } // lib.optionalAttrs (config.claude.enabledPlugins != []) {
    enabledPlugins = builtins.listToAttrs (
      map (id: { name = id; value = true; }) config.claude.enabledPlugins
    );
  });

  settingsFile = pkgs.writeText "claude-settings.json" settingsJson;

  writeClaudeSettings = pkgs.writeShellScript "write-claude-settings" ''
    mkdir -p "$HOME/.claude"
    install -m 644 ${settingsFile} "$HOME/.claude/settings.json"
  '';

  trustHomeDirectory = pkgs.writeShellScript "trust-home-directory" ''
    CLAUDE_JSON="$HOME/.claude.json"
    HOME_DIR="${config.home.homeDirectory}"
    if [ ! -f "$CLAUDE_JSON" ]; then
      echo '{"projects":{}}' > "$CLAUDE_JSON"
    fi
    ${pkgs.jq}/bin/jq --arg homedir "$HOME_DIR" \
      '.projects[$homedir].hasTrustDialogAccepted = true' \
      "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp" && \
      mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
  '';
in
{
  options.claude = {
    enabledPlugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of Claude plugin IDs to enable in settings.json";
    };
  };

  config = {
    programs.claude-code = {
      enable = true;
      package = pkgs-unstable.claude-code;
    };

    home.activation.writeClaudeSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${writeClaudeSettings}
    '';

    home.activation.trustClaudeHomeDirectory = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${trustHomeDirectory}
    '';
  };
}
