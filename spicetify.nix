{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  name = "spicetify-2.9.9";

  src = pkgs.fetchurl {
    name = "spicetify-2.9.9-linux-amd64.tar.gz";
    url = https://github.com/spicetify/spicetify-cli/releases/download/v2.9.9/spicetify-2.9.9-linux-amd64.tar.gz;
    sha256 = "0vasp8cyzzdag0zil6b2ix99lbzskny4nhz7vq5bx8x2bb7qyxc6";
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';
}
