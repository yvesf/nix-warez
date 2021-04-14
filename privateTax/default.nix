{ version, sha256, ...}:

{ writeTextFile, lib , stdenv, makeDesktopItem, fetchurl, buildFHSUserEnv
, udev, jre, texFunctions, ... }:
let
  responseVarfile = writeTextFile {
    name = "response.varfile";
    text = ''
      sys.programGroupDisabled$Boolean=false
      sys.component.Monitor\ Agent$Boolean=true
      sys.component.Common$Boolean=true
      sys.component.Controller$Boolean=true
      sys.languageId=de
      sys.component.Load\ Generator$Boolean=true
      sys.installationTypeId=Controller
      sys.installationDir=INSTALLDIR/lib/ptlx
      sys.symlinkDir=INSTALLDIR/bin
    '';
  };
  desktopItem = makeDesktopItem {
    type = "Application";
    name = "PrivateTax${version}";
    desktopName = "Private Tax ${version}";
    exec = "PrivateTax${version}";
  };
  privateTax = stdenv.mkDerivation rec {
    inherit version;
    name = "ptlx-${version}";

    src = fetchurl {
      url = "https://www.zh.ch/content/dam/zhweb/bilder-dokumente/themen/steuern-finanzen/steuern/natuerlichepersonen/release_installer/ptlx${builtins.substring 2 2 version}_64.sh";
      inherit sha256;
    };

    nativeBuildInputs = [ jre ];
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/lib/ptlx

      sed -e 's/^if \[ -f jre.tar.gz/if false          /' $src > installer
      chmod a+x installer
      sed -e "s|INSTALLDIR|$out|" ${responseVarfile} > response.varfile


      export HOME=`pwd`
      export INSTALL4J_JAVA_HOME=${jre.home}
      export FONTCONFIG_FILE=${texFunctions.fontsConf}

      bash -ic './installer -q -varfile response.varfile'
    '';

    meta = with lib; {
      description = "TODO";
      homepage = "";
      license = licenses.unfree;
      platforms = platforms.linux;
      maintainers = with maintainers; [ yvesf ];
    };
  };
in
  buildFHSUserEnv rec {
    name = "PrivateTax${version}";
    runScript = "${privateTax}/lib/ptlx/Private\\ Tax\\ ${version}";

    extraInstallCommands = ''
      mkdir -p "$out/share/applications"
      cp "${desktopItem}/share/applications/"* $out/share/applications
    '';

    targetPkgs = _: [ udev ];
  }
