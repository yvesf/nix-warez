{ lib, stdenv, fetchurl, dpkg, autoPatchelfHook,
glib, pango, gtk2-x11, libsm, ...}:
  stdenv.mkDerivation rec {
    name = "tpps2";
    version = "1.24";

    src = fetchurl {
      url = "https://www.ta.co.at/fileadmin/Downloads/Software/TAPPS2/Linux/64bit/tapps2-1.24-amd64.deb";
      hash = "sha256-2HsSd861UssFSrFyeKRE5UcEsEuuNscbx20q/ZRXU3A=";
    };

    nativeBuildInputs = [ dpkg autoPatchelfHook ];

    buildInputs = [
      glib
      pango
      gtk2-x11
      libsm
    ];

    unpackPhase = ''
      dpkg-deb -x $src unpack
    '';

    installPhase = ''
      mkdir -p $out
      cp -r unpack/usr/share $out
      
      mkdir -p $out/bin
      ln -s -r $out/share/Technische-Alternative/Tapps2/Tapps2 $out/bin/tpps2
    '';

    meta = with lib; {
      description = "Die Programmier- und Planungssoftware TAPPS2 ermöglicht das Erstellen eines Logikschaltbildes und die Parametrierung aller x2 Geräte (und der UVR1611).";
      homepage = "https://www.ta.co.at/download/software";
      license = licenses.unfree;
      platforms = platforms.linux;
      maintainers = with maintainers; [ yvesf ];
    };
  }
