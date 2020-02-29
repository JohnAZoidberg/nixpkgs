{ stdenv, fetchurl, pkg-config, glib, gperf, util-linux, kmod }:
stdenv.mkDerivation rec {
  pname = "eudev";
  version = "3.2.10";

  src = fetchurl {
    url = "http://dev.gentoo.org/~blueness/eudev/eudev-${version}.tar.gz";
    sha256 = "sha256-h7sCjUcP0bhRaTSbRMVdW3M3M9wtUN3xGW4CZyXq0DQ=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    glib gperf util-linux kmod
  ];

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
  ];

  makeFlags = [
    "hwdb_bin=/var/lib/udev/hwdb.bin"
    "udevrulesdir=/etc/udev/rules.d"
  ];

  preInstall = ''
    # Disable install-exec-hook target as it conflicts with our move-sbin setup-hook
    sed -i 's;$(MAKE) $(AM_MAKEFLAGS) install-exec-hook;$(MAKE) $(AM_MAKEFLAGS);g' src/udev/Makefile
  '';

  installFlags = [
    "localstatedir=$(TMPDIR)/var"
    "sysconfdir=$(out)/etc"
    "udevconfdir=$(out)/etc/udev"
    "udevhwdbbin=$(out)/var/lib/udev/hwdb.bin"
    "udevhwdbdir=$(out)/var/lib/udev/hwdb.d"
    "udevrulesdir=$(out)/var/lib/udev/rules.d"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "A udev fork by Gentoo";
    license = stdenv.lib.licenses.gpl2Plus ;
    maintainers = with stdenv.lib.maintainers; [ raskin ];
    platforms = stdenv.lib.platforms.linux;
    homepage = "https://wiki.gentoo.org/wiki/Project:Eudev";
    downloadPage = "http://dev.gentoo.org/~blueness/eudev/";
    updateWalker = true;
  };
}
