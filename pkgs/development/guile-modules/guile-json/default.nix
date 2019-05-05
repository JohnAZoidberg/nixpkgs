{ stdenv, fetchurl, autoreconfHook, pkgconfig, guile }:
stdenv.mkDerivation rec {
  pname = "guile-json";
  version = "3.2.0";

  src = fetchurl {
    url = "mirror://savannah/${pname}/${pname}-${version}.tar.gz";
    sha256 = "14m6b6g2maw0mkvfm4x63rqb54vgbpn1gcqs715ijw4bikfzlqfz";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ guile ];

  meta = with stdenv.lib; {
    description = "JSON module for Guile";
    longDescription = ''
      - Strictly complies to http://json.org specification.
      - Build JSON documents programmatically via macros.
      - Unicode support for strings.
      - Allows JSON pretty printing.
    '';
    homepage = "https://savannah.nongnu.org/projects/guile-json/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.unix;
  };
}
