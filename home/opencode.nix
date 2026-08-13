{ pkgs, ... }:

let
  # nixpkgs' own opencode build corrupts the embedded Bun payload's segment
  # order, causing a SIGSEGV on every invocation (upstream anomalyco/opencode#26846).
  # Fetching the official release tarball unmodified (dontFixup, no patchelf)
  # and relying on nix-ld (programs.nix-ld.enable in configuration.nix) for the
  # interpreter avoids the corruption entirely. Bump version + sha256 to upgrade.
  opencode = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "opencode";
    version = "1.18.18";

    src = pkgs.fetchurl {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
      sha256 = "1bravfgirc3nmkb86kd21pq8hw6s1h69ia05k5k571cb84ic5p8c";
    };

    sourceRoot = ".";
    dontFixup = true;

    installPhase = ''
      install -Dm755 opencode $out/bin/opencode
    '';
  };
in
{
  home.packages = [ opencode ];
}
