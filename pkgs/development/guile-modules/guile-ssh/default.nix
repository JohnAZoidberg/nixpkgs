{ stdenv, fetchFromGitHub, fetchpatch, autoreconfHook, pkgconfig, which, texinfo, guile, libssh }:
stdenv.mkDerivation rec {
  pname = "guile-ssh";
  version = "0.11.3";

  src = fetchFromGitHub {
    owner = "artyom-poptsov";
    repo = pname;
    rev = "v${version}";
    sha256 = "03bv3hwp2s8f0bqgfjaan9jx4dyab0abv27n2zn2g0izlidv0vl6";
  };

  patches = [
    # See: https://github.com/artyom-poptsov/guile-ssh/issues/9
    (fetchpatch {
      url = "https://github.com/artyom-poptsov/guile-ssh/commit/01cafef0dd87b6afda41942070e73b55b45a5ed2.diff";
      sha256 = "0ss16p1761i74s4ys5dhhhhyfpijx18rk8lgij55p29bdvqgsabw";
    })
  ];
  nativeBuildInputs = [ autoreconfHook pkgconfig which texinfo ];  # Which is probably a hack
  buildInputs = [ guile libssh ]; # Maybe use libssh2

  meta = with stdenv.lib; {
    description = "Provides access to the SSH protocol for GNU Guile";
    homepage = "https://github.com/artyom-poptsov/guile-ssh";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.unix;
  };
}
