{ stdenv, fetchFromGitHub, pkg-config, fuse2, libxml2 }:
stdenv.mkDerivation rec {
  pname = "xmlfs";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "halhen";
    repo = "xmlfs";
    rev = version;
    sha256 = "10bb6qa6bbbfb4ggl8jlz56k7bq5s07p5r5bn3z4yimkqkw9z553";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ fuse2 libxml2 ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "Mount xml files as directory structures using FUSE";
    platforms = platforms.linux;
    license = licenses.gpl2;
    maintainers = with maintainers; [ johnazoidberg ];
  };
}
