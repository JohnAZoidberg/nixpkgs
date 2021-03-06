{ stdenv
, fetchurl
, nixosTests
, fixDarwinDylibNames
, meson
, ninja
, pkg-config
, gettext
, python3
, libxml2
, libxslt
, docbook-xsl-nons
, docbook_xml_dtd_43
, gtk-doc
, glib
, libtiff
, libjpeg
, libpng
, gnome3
, gobject-introspection
, doCheck ? false
, makeWrapper
, fetchpatch
}:

stdenv.mkDerivation rec {
  pname = "gdk-pixbuf";
  version = "2.40.0";

  outputs = [ "out" "dev" "man" "devdoc" "installedTests" ];

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "1rnlx9yfw970maxi2x6niaxmih5la11q1ilr7gzshz2kk585k0hm";
  };

  patches = [
    # Move installed tests to a separate output
    ./installed-tests-path.patch

    # Temporary until the fix is released.
    (fetchpatch {
      name = "tests-circular-table.patch";
      url = "https://gitlab.gnome.org/GNOME/gdk-pixbuf/merge_requests/59.diff";
      sha256 = "0kaflac3mrh6031hwxk7j9fhli775hc503818h8zfl6b28zyn93f";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    python3
    libxml2
    libxslt
    docbook-xsl-nons
    docbook_xml_dtd_43
    gtk-doc
    gobject-introspection
    makeWrapper
    glib
  ] ++ stdenv.lib.optional stdenv.isDarwin [
    fixDarwinDylibNames
  ];

  propagatedBuildInputs = [
    glib
    libtiff
    libjpeg
    libpng
  ];

  mesonFlags = [
    "-Ddocs=true"
    "-Dx11=false" # use gdk-pixbuf-xlib
    "-Dgir=${if gobject-introspection != null then "true" else "false"}"
    "-Dgio_sniffing=false"
  ];

  postPatch = ''
    chmod +x build-aux/* # patchShebangs only applies to executables
    patchShebangs build-aux

    substituteInPlace tests/meson.build --subst-var-by installedtestsprefix "$installedTests"
  '';

  postInstall =
    # meson erroneously installs loaders with .dylib extension on Darwin.
    # Their @rpath has to be replaced before gdk-pixbuf-query-loaders looks at them.
    stdenv.lib.optionalString stdenv.isDarwin ''
      for f in $out/${passthru.moduleDir}/*.dylib; do
          install_name_tool -change @rpath/libgdk_pixbuf-2.0.0.dylib $out/lib/libgdk_pixbuf-2.0.0.dylib $f
          mv $f ''${f%.dylib}.so
      done
    ''
    # All except one utility seem to be only useful during building.
    + ''
      moveToOutput "bin" "$dev"
      moveToOutput "bin/gdk-pixbuf-thumbnailer" "$out"
    '' + stdenv.lib.optionalString (stdenv.hostPlatform == stdenv.buildPlatform) ''
      # We need to install 'loaders.cache' in lib/gdk-pixbuf-2.0/2.10.0/
      $dev/bin/gdk-pixbuf-query-loaders --update-cache
    '';

  # The fixDarwinDylibNames hook doesn't patch binaries.
  preFixup = stdenv.lib.optionalString stdenv.isDarwin ''
    for f in $out/bin/* $dev/bin/*; do
        install_name_tool -change @rpath/libgdk_pixbuf-2.0.0.dylib $out/lib/libgdk_pixbuf-2.0.0.dylib $f
    done
  '';

  preInstall = ''
    PATH=$PATH:$out/bin # for install script
  '';

  # The tests take an excessive amount of time (> 1.5 hours) and memory (> 6 GB).
  inherit doCheck;

  setupHook = ./setup-hook.sh;

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
    };

    tests = {
      installedTests = nixosTests.installed-tests.gdk-pixbuf;
    };

    # gdk_pixbuf_moduledir variable from gdk-pixbuf-2.0.pc
    moduleDir = "lib/gdk-pixbuf-2.0/2.10.0/loaders";
  };

  meta = with stdenv.lib; {
    description = "A library for image loading and manipulation";
    homepage = "https://gitlab.gnome.org/GNOME/gdk-pixbuf";
    maintainers = [ maintainers.eelco ] ++ teams.gnome.members;
    license = licenses.lgpl21;
    platforms = platforms.unix;
  };
}
