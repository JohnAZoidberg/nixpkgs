{ stdenv, swiProlog, makeWrapper, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "ape";
  version = "6.7.180715";

  buildInputs = [ swiProlog makeWrapper ];

  src = fetchFromGitHub {
     owner = "Attempto";
     repo = "APE";
     rev = version;
     sha256 = "1jnr6y4kc6d5rjy6bbbnn4n7rl6ajpvw4xf4067wjh28c9scjwg3";
  };

  patches = [ ./fix-build-system.patch ];

  postInstall = ''
    install -Dm755 ape.exe $out/bin/ape
    wrapProgram $out/bin/ape --add-flags ace
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Parser for Attempto Controlled English (ACE)";
    homepage = "https://github.com/Attempto/APE";
    license = licenses.lgpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ yrashk ];
  };
}
