{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, guile }:
stdenv.mkDerivation rec {
  pname = "guile-bytestructures";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "TaylanUB";
    repo = "scheme-bytestructures";
    rev = "v${version}";
    sha256 = "13pn35yrpsqhhcq3j881yhfl3n3f610s1jwja3wrgvab0wx8w12d";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ guile ];

  meta = with stdenv.lib; {
    description = "Structured access to bytevector contents";
    longDescription = ''
      This library offers a system imitating the type system of the C
      programming language, to be used on bytevectors. C's type system works on
      raw memory, and ours works on bytevectors which are an abstraction over
      raw memory in Scheme. The system is in fact more powerful than the C type
      system, elevating types to first-class status.
    '';
    homepage = "https://github.com/TaylanUB/scheme-bytestructures";
    license = with licenses; [ gpl3Plus ];
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.unix;
  };
}
