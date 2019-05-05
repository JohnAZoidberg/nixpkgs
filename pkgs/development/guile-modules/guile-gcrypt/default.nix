{ stdenv, fetchurl, autoreconfHook, pkgconfig, texinfo, guile, libgcrypt }:
stdenv.mkDerivation rec {
  pname = "guile-gcrypt";
  version = "0.2.0";

  src = fetchurl {
    url = "https://notabug.org/cwebber/${pname}/archive/v${version}.tar.gz";
    sha256 = "1ffgq6a219v80rjdnl8g7ybh6w0cc2627nnz27w0wnmjpf50wns1";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig texinfo ];
  buildInputs = [ guile libgcrypt ];

  GUILE_AUTO_COMPILE = 0;

  meta = with stdenv.lib; {
    description = "Guile bindings to Libgcrypt";
    longDescription = ''
      Guile-Gcrypt provides modules for cryptographic hash functions,
      message authentication codes (MAC), public-key cryptography, strong
      randomness, and more. It is implemented using the foreign function
      interface (FFI) of Guile.
    '';
    homepage = "https://notabug.org/cwebber/guile-gcrypt";
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.unix;
  };
}
