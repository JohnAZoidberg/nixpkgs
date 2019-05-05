{ stdenv, lib, fetchurl, pkgconfig, texinfo, autoreconfHook, help2man, perlPackages
, guile, guile-gcrypt, guile-sqlite3, guile-git, guile-json
, zlib, gnutls, nix
# Support for build offloading and guix copy
, guile-ssh ? null
# When lzlib is available, lzlib substitutes can be used and guix publish can compress substitutes with lzlib.
, lzlib ? null
# When bzip2 is available, guix-daemon can use it to compress build logs.
, bzip2 ? null
# We don't need the daemon on NixOS because the Nix daemon can the same job
, withDaemon ? false, libgcrypt, sqlite
}:

assert withDaemon -> libgcrypt != null && sqlite != null;

stdenv.mkDerivation rec {
  pname = "guix";
  version = "1.0.1";

  #src = /home/zoid/media/clone/active/guix/.;
  src = fetchurl {
    url = "mirror://gnu/${pname}/${pname}-${version}.tar.gz";
    sha256 = "0pza612d67fkmzc56knzdziw4f8d58fzk0hbxq7jjq8nl77vcf9r";
  };

  postPatch = ''
    ./bootstrap
  '';

  nativeBuildInputs = [
    pkgconfig
    autoreconfHook
    texinfo help2man
    perlPackages.Po4a
  ] ++ lib.optionals (!withDaemon) [
    nix
  ];

  configureFlags = lib.optionals (!withDaemon) [
    "--disable-daemon"
    "--with-store-dir=/nix/store"
    "--localstatedir=/nix/var"
  ];

  GUILE_WARN_DEPRECATED = "detailed";

  # perlPackages.Po4a can't be included in nativeBuildInputs because it brings
  # its own glibc which breaks the build. See nixos/nixpkgs#61035
  preConfigure = ''
    export PATH="${perlPackages.Po4a}/bin:$PATH"
  '';

  buildInputs = [
    guile guile-gcrypt guile-sqlite3 guile-git guile-json gnutls zlib
    guile-ssh lzlib bzip2  # Guile-SSH
  ] ++ lib.optionals withDaemon [
    libgcrypt sqlite
  ];

  enableParallelBuilding = true;
  enableParallelChecking = true;

  # Can be set to true
  doCheck = false;

  # consider setting GUIX_DAEMON_SOCKET= /nix/var/nix/daemon-socket/socket

  meta = with lib; {
    description = "The GNU Guix package manager";
    homepage = "https://www.gnu.org/software/guix/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = [ "aarch64-linux" "i686-linux" "x86_64-linux" "mips64el-linux" "armhf-linux" ];
  };
}
