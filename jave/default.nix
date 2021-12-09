{ makeDesktopItem, lib, stdenv, fetchurl, jre, unzip, runtimeShell, ...}:
let
  desktopItem = launcher: makeDesktopItem {
    type = "Application";
    name = "JavE";
    desktopName = "JavE";
    exec = "${launcher}";
  };
in
  stdenv.mkDerivation rec {
    name = "jave-${version}";
    version = "6.0_RC2";

    src = fetchurl {
      url = "http://www.jave.de/developer/jave_6.0_RC2.zip";
      sha256 = "1wbjd2w8rixhk2jr2dpd5ir3sqa05rwlhlanasfnr2pwpbg39l6y";
    };

    nativeBuildInputs = [ jre unzip ];
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/lib/jave
      unzip ${src} -d $out/lib/jave

      mkdir -p $out/bin
      cat >$out/bin/jave <<EOF
      #!${runtimeShell}
      exec ${jre}/bin/java -jar $out/lib/jave/jave.jar
      EOF
      chmod +x $out/bin/jave

      ${(desktopItem "$out/bin/jave").buildCommand}
    '';

    meta = with lib; {
      description = "JavE is a free Ascii Editor. Rather than for editing texts, it is intended for drawing simple diagrams by using Ascii characters.";
      homepage = "http://jave.de/";
      license = licenses.unfree;
      platforms = platforms.linux;
      maintainers = with maintainers; [ yvesf ];
    };
  }
