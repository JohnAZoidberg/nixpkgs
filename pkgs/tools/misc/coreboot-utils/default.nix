{
  lib,
  stdenv,
  fetchgit,
  pkg-config,
  zlib,
  pciutils,
  openssl,
  coreutils,
  acpica-tools,
  makeWrapper,
  go,
  gnugrep,
  gnused,
  file,
  buildEnv,
}:

let
  version = "26.06";

  vbootSrc = fetchgit {
    url = "https://review.coreboot.org/vboot";
    rev = "5c360ef458b0a013d8a6d47724bb0fffb5accbcf";
    hash = "sha256-BZdyUPa9RD2txjFfgcyEQEG+Z6yPJpXRdwTe1ExwaSs=";
  };

  commonMeta = {
    description = "Various coreboot-related tools";
    homepage = "https://www.coreboot.org";
    license = with lib.licenses; [
      gpl2Only
      gpl2Plus
    ];
    maintainers = with lib.maintainers; [
      felixsinger
      jmbaur
    ];
    platforms = lib.platforms.linux;
  };

  generic =
    {
      pname,
      path ? "util/${pname}",
      # Only cbfstool (and the tools built from its Makefile) need vboot.
      needsVboot ? false,
      ...
    }@args:
    stdenv.mkDerivation (
      finalAttrs:
      {
        inherit pname version;

        src = fetchgit {
          url = "https://review.coreboot.org/coreboot";
          rev = finalAttrs.version;
          fetchSubmodules = false;
          hash = "sha256-lnO2U/VZC5IhvTF0ZGfoy4K/1YXojeMVIdcBi8rAOFo=";
        };

        enableParallelBuilding = true;

        postPatch = ''
          ${lib.optionalString needsVboot ''
            mkdir -p 3rdparty/vboot
            cp -r --no-preserve=mode,ownership ${vbootSrc}/. 3rdparty/vboot/
            substituteInPlace 3rdparty/vboot/Makefile --replace-fail 'ar qcT ' '$$AR qcT '
          ''}
          cd ${path}
          patchShebangs .
        '';

        makeFlags = [
          "INSTALL=install"
          "PREFIX=${placeholder "out"}"
        ];

        meta = commonMeta // args.meta;
      }
      // (removeAttrs args [
        "meta"
        "needsVboot"
      ])
    );

  utils = {
    msrtool = generic {
      pname = "msrtool";
      meta.description = "Dump chipset-specific MSR registers";
      meta.platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
      buildInputs = [
        pciutils
        zlib
      ];
      preConfigure = "export INSTALL=install";
    };
    cbmem = generic {
      pname = "cbmem";
      meta.description = "Coreboot console log reader";
    };
    ifdtool = generic {
      pname = "ifdtool";
      meta.description = "Extract and dump Intel Firmware Descriptor information";
    };
    intelmetool = generic {
      pname = "intelmetool";
      meta.description = "Dump interesting things about Management Engine";
      meta.platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
      buildInputs = [
        pciutils
        zlib
      ];
    };
    cbfstool = generic {
      pname = "cbfstool";
      needsVboot = true;
      meta.description = "Management utility for CBFS formatted ROM images";
    };
    nvramtool = generic {
      pname = "nvramtool";
      meta.description = "Read and write coreboot parameters and display information from the coreboot table in CMOS/NVRAM";
      meta.mainProgram = "nvramtool";
      meta.platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
    };
    superiotool = generic {
      pname = "superiotool";
      meta.description = "User-space utility to detect Super I/O of a mainboard and provide detailed information about the register contents of the Super I/O";
      meta.platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
      buildInputs = [
        pciutils
        zlib
      ];
    };
    ectool = generic {
      pname = "ectool";
      meta.description = "Dump the RAM of a laptop's Embedded/Environmental Controller (EC)";
      meta.platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
      preInstall = "mkdir -p $out/sbin";
    };
    inteltool = generic {
      pname = "inteltool";
      meta.description = "Provides information about Intel CPU/chipset hardware configuration (register contents, MSRs, etc)";
      meta.platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
      buildInputs = [
        pciutils
        zlib
      ];
    };
    amdfwtool = generic {
      pname = "amdfwtool";
      meta.description = "Create AMD firmware combination";
      buildInputs = [ openssl ];
      nativeBuildInputs = [ pkg-config ];
      installPhase = ''
        runHook preInstall

        install -Dm755 amdfwtool $out/bin/amdfwtool

        runHook postInstall
      '';
    };
    acpidump-all = generic {
      pname = "acpidump-all";
      path = "util/acpi";
      meta.description = "Walk through all ACPI tables with their addresses";
      nativeBuildInputs = [ makeWrapper ];
      dontBuild = true;
      installPhase = ''
        runHook preInstall

        install -Dm755 acpidump-all $out/bin/acpidump-all

        runHook postInstall
      '';
      postFixup = ''
        wrapProgram $out/bin/acpidump-all \
          --set PATH ${
            lib.makeBinPath [
              coreutils
              acpica-tools
              gnugrep
              gnused
              file
            ]
          }
      '';
    };
    # buildGoModule for some reason does not generate a binary
    intelp2m = generic {
      pname = "intelp2m";
      version = "2.5";
      env = {
        VERSION = "2.5-${version}";
        GOCACHE = "/tmp/go-cache";
      };
      nativeBuildInputs = [ go ];
      installPhase = ''
        runHook preInstall

        install -Dm755 intelp2m $out/bin/intelp2m

        runHook postInstall
      '';
      meta.description = "Convert the inteltool register dump to gpio.h with GPIO configuration for porting coreboot";
    };
  };

in
utils
// {
  coreboot-utils = (
    buildEnv {
      pname = "coreboot-utils";
      inherit version;
      meta = commonMeta;
      paths = lib.filter (lib.meta.availableOn stdenv.hostPlatform) (lib.attrValues utils);
      postBuild = "rm -rf $out/sbin";
    }
  );
}
