{ config, ... }:

{
  # npm's default global prefix lives inside the read-only Nix store;
  # redirect it to a writable location so `npm install -g` works.
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.local/share/npm-global";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/share/npm-global/bin"
  ];
}
