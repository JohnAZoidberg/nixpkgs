{ stdenv, fetchFromGitHub, nodejs }:

stdenv.mkDerivation rec {
  name = "nodebb-${version}";
  version = "1.7.4";

  src = fetchFromGitHub {
    owner = "NodeBB";
    repo = "NodeBB";
    rev = "v${version}";
    sha256 = "1x7f1yz5vnsy9n50ak0vjrm4w8fqc1qvhv8fmqnsc8cgbp7f3p8w";
  };

  buildInputs = [ nodejs ];

  installPhase = ''
    mkdir $out
    cp -a * $out/
  '';

  meta = with stdenv.lib; {
    description = "NodeBB is a next generation forum software that's free and easy to use.";
    license = licenses.gpl3;
    homepage = https://nodebb.org;
    maintainers = with maintainers; [ johnazoidberg lschuermann ];
  };
}
