{ pkgs, lib, ... }:

let
  maxBackups = 20;
  minRetentionDays = 7;
  oneDrivePath = "NixOS/user-config";

  backupScript = pkgs.writeShellScript "user-config-backup" ''
    set -euo pipefail

    SOURCE_DIR="$HOME/.nixos-config/home/user-config"
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

    # Resolve OneDrive path from Windows environment
    ONEDRIVE_WIN=$(/mnt/c/WINDOWS/system32/cmd.exe /c "echo %OneDriveCommercial%" 2>/dev/null | tr -d '\r\n')
    if [ -z "$ONEDRIVE_WIN" ] || [ "$ONEDRIVE_WIN" = "%OneDriveCommercial%" ]; then
      echo "Warning: Could not resolve OneDrive path, skipping user-config backup"
      exit 0
    fi

    # Convert Windows path to WSL path
    DRIVE_LETTER=$(echo "$ONEDRIVE_WIN" | cut -c1 | tr '[:upper:]' '[:lower:]')
    ONEDRIVE_WSL="/mnt/$DRIVE_LETTER/$(echo "$ONEDRIVE_WIN" | cut -c4- | tr '\\' '/')"
    BACKUP_ROOT="$ONEDRIVE_WSL/${oneDrivePath}"

    mkdir -p "$BACKUP_ROOT/$TIMESTAMP"

    # Copy all .nix files except .example templates
    find "$SOURCE_DIR" -maxdepth 1 -name '*.nix' ! -name '*.nix.example' -exec cp {} "$BACKUP_ROOT/$TIMESTAMP/" \;

    if [ -z "$(ls -A "$BACKUP_ROOT/$TIMESTAMP/" 2>/dev/null)" ]; then
      rmdir "$BACKUP_ROOT/$TIMESTAMP"
      echo "No user-config files to backup"
      exit 0
    fi

    echo "Backed up user-config to $BACKUP_ROOT/$TIMESTAMP/"

    # Prune old backups beyond maxBackups, but never delete backups younger than minRetentionDays
    cd "$BACKUP_ROOT"
    CUTOFF=$(date -d "${toString minRetentionDays} days ago" +"%Y%m%d-%H%M%S")
    BACKUP_COUNT=$(find . -maxdepth 1 -mindepth 1 -type d | wc -l)
    if [ "$BACKUP_COUNT" -gt ${toString maxBackups} ]; then
      find . -maxdepth 1 -mindepth 1 -type d | sort | head -n $(( BACKUP_COUNT - ${toString maxBackups} )) | while read -r dir; do
        DIR_NAME=$(basename "$dir")
        if [ "$DIR_NAME" \< "$CUTOFF" ]; then
          rm -rf "$dir"
          echo "Pruned old backup: $dir"
        fi
      done
    fi
  '';
in
{
  home.activation.backupUserConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${backupScript}
  '';
}
