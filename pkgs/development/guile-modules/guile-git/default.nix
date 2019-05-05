{ stdenv, fetchFromGitLab, autoreconfHook, pkgconfig, texinfo
, guile, guile-bytestructures, libgit2
}:
stdenv.mkDerivation rec {
  pname = "guile-git";
  version = "0.2.0";

  src = fetchFromGitLab {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "018hmfsh0rjwfvr4h7y10jc6k8a2k9xsirngghy3pjasin4nd2yz";
  };

  GUILE_AUTO_COMPILE = 0;

  nativeBuildInputs = [ autoreconfHook pkgconfig texinfo ];
  buildInputs = [ guile libgit2 ];
  propagatedBuildInputs = [ guile-bytestructures ];

  meta = with stdenv.lib; {
    description = "Guile bindings to libgit2";
    homepage = "https://gitlab.com/guile-git/guile-git";
    license = with licenses; [ gpl2Plus lgpl3Plus] ;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.unix;
  };
}
