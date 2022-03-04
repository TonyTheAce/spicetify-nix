{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  name = "spicetify-2.8.3";

  src = pkgs.fetchurl {
    name = "spicetify-2.8.5-linux-amd64.tar.gz";
    url = https://github.com/khanhas/spicetify-cli/releases/download/v2.8.5/spicetify-2.8.5-linux-amd64.tar.gz;
    sha256 = "sha256:17hshzy9y66ja8syb069dl80icbh0mabx9092cl4h3cgc03v4fnf";
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';
}