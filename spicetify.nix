{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  name = "spicetify-2.8.3";

  src = pkgs.fetchurl {
    name = "spicetify-2.8.5-linux-amd64.tar.gz";
    url = https://github.com/spicetify/spicetify-cli/releases/download/v2.9.4/spicetify-2.9.4-linux-amd64.tar.gz;
    sha256 = "0py8mhnwd6z1k373p43w5p07amnf40274jhswv09pp9ijl8rgff9";
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';
}