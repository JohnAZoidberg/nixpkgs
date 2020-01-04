{ stdenv, fetchFromGitHub, cmake, curl, jansson, readline }:

stdenv.mkDerivation rec {
  pname = "libredfish";
  version = "1.2.7";

  nativeBuildInputs = [ cmake ];

  buildInputs = [ curl jansson readline ];

  src = fetchFromGitHub {
    owner = "DMTF";
    repo = pname; 
    rev = version;
    sha256 = "1f6jwz8wddygbnhjf9fsz46wxb55fr5jsa75xx71dgyph97k9zpa";
  };

  meta = with stdenv.lib; {
    description = "A C client library for the Redfish server management protocol";
    homepage = "https://www.dmtf.org/standards/redfish";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ johnazoidberg ];
  };
}
