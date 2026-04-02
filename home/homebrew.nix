{ pkgs, lib, config, ... }:

let
  cfg = config.homebrew;
  brewPrefix = "/home/linuxbrew/.linuxbrew";

  brewfileContent = lib.concatStringsSep "\n" (
    (lib.mapAttrsToList (name: url: ''tap "${name}", "${url}"'') cfg.taps)
    ++ (map (f: ''brew "${f}"'') cfg.brews)
    ++ [ "" ]
  );

  brewfile = pkgs.writeText "Brewfile" brewfileContent;

  azureCli = pkgs.azure-cli.withExtensions [
    pkgs.azure-cli.extensions.azure-devops
  ];

  targetPkgs = pkgs: with pkgs; [
    azureCli
    bash
    cacert
    coreutils
    curl
    file
    findutils
    gcc
    git
    glibc
    gnugrep
    icu
    gnumake
    gnused
    gnutar
    gzip
    linuxHeaders
    openssh
    openssl
    patch
    procps
    python3
    ruby
    which
    xz
    zlib
  ];

  profile = ''
    export HOMEBREW_PREFIX="${brewPrefix}"
    export HOMEBREW_CELLAR="${brewPrefix}/Cellar"
    export HOMEBREW_REPOSITORY="${brewPrefix}"
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_INSTALL_CLEANUP=1
    export AZURE_EXTENSION_DIR="$HOME/.azure/cliextensions"
    export PATH="${brewPrefix}/bin:${brewPrefix}/sbin:$PATH"
  '';

  brewSetup = pkgs.buildFHSEnv {
    name = "brew-setup";
    inherit targetPkgs profile;
    runScript = "${pkgs.writeShellScript "brew-setup-run" ''
      set -euo pipefail

      if [ ! -x "${brewPrefix}/bin/brew" ]; then
        echo "Installing Homebrew to ${brewPrefix}..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi

      # Pre-install azure-devops extension using nix's az so brew formulas
      # that depend on it don't need to pip-install it inside the sandbox.
      mkdir -p "$AZURE_EXTENSION_DIR"
      if [ ! -d "$AZURE_EXTENSION_DIR/azure-devops" ]; then
        ${azureCli}/bin/az extension add --name azure-devops --only-show-errors 2>/dev/null || true
      fi

      LOCKDIR="$HOME/.config/homebrew"
      mkdir -p "$LOCKDIR"
      install -m 644 "${brewfile}" "$LOCKDIR/Brewfile"
      brew bundle --file="$LOCKDIR/Brewfile"
      echo "Homebrew bundle complete. Lock file at $LOCKDIR/Brewfile.lock.json"
    ''}";
  };

  brew = pkgs.buildFHSEnv {
    name = "brew";
    inherit targetPkgs profile;
    runScript = "${pkgs.writeShellScript "brew-cmd" ''
      if [ ! -x "${brewPrefix}/bin/brew" ]; then
        echo "Homebrew is not installed. Run home-switch to install it."
        exit 1
      fi
      exec "${brewPrefix}/bin/brew" "$@"
    ''}";
  };

  brewShell = pkgs.buildFHSEnv {
    name = "brew-shell";
    inherit targetPkgs profile;
    runScript = "bash";
  };

  brewRunFHS = pkgs.buildFHSEnv {
    name = "brew-run-fhs";
    inherit targetPkgs profile;
    extraBwrapArgs = [
      "--ro-bind" "/usr/bin" "/host-usr-bin"
    ];
    runScript = "${pkgs.writeShellScript "brew-exec" ''
      export PATH="/host-usr-bin:$PATH"

      # WSL .exe interop doesn't work inside bwrap (both use /init).
      # Override docker config to disable the .exe credential helper.
      if [ -f "$HOME/.docker/config.json" ] && grep -q '"credsStore"' "$HOME/.docker/config.json"; then
        export DOCKER_CONFIG="$HOME/.docker-fhs"
        mkdir -p "$DOCKER_CONFIG"
        python3 -c "
import json, sys
c = json.load(open(sys.argv[1]))
c.pop('credsStore', None)
json.dump(c, open(sys.argv[2], 'w'), indent=2)
" "$HOME/.docker/config.json" "$DOCKER_CONFIG/config.json"
      fi

      exec "$@"
    ''}";
  };

  brewRun = pkgs.writeShellScriptBin "brew-run" ''
    exec ${brewRunFHS}/bin/brew-run-fhs "$@"
  '';
in
{
  options.homebrew = {
    taps = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Homebrew taps as name -> git URL.";
    };

    brews = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Homebrew formulas to install.";
    };

  };

  config = lib.mkIf (cfg.brews != []) {
    home.packages = [
      brew
      brewRun
      brewShell
    ];

    programs.zsh.initContent = let
      formulaNames = map (f: lib.last (lib.splitString "/" f)) cfg.brews;
      scanSnippet = lib.concatMapStringsSep "\n" (name: ''
        for _bin in "${brewPrefix}/Cellar/${name}"/*/bin/*; do
          [ -x "$_bin" ] && alias "$(basename "$_bin")"="brew-run $(basename "$_bin")"
        done
      '') formulaNames;
    in ''
      # Auto-alias brew-installed binaries through FHS env
      ${scanSnippet}
      unset _bin
    '';

    home.activation.brewBundle = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "${brewPrefix}" ]; then
        run /run/wrappers/bin/sudo mkdir -p "${brewPrefix}"
        run /run/wrappers/bin/sudo chown "$(id -un):$(id -gn)" "${brewPrefix}"
      fi
      run ${brewSetup}/bin/brew-setup
    '';
  };
}
