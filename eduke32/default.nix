{ eduke32, p7zip, makeDesktopItem, lib, stdenv, fetchurl, runtimeShell, ...}:
let
  desktopItem = launcher: suffix: makeDesktopItem {
    type = "Application";
    name = "eduke32 HRP" + suffix;
    desktopName = "eduke 32 HRP";
    exec = "${launcher}";
  };
in
  stdenv.mkDerivation rec {
    name = "eduke32-${version}";
    version = eduke32.version;

    src = fetchurl {
      url = http://www.duke4.org/files/nightfright/hrp/dn3d_hrp54-sfx.exe;
      sha256 = "1a0sg9pigdn78fmiz9s0rr607b5rybryqsbivy5j6p400h3x0lyl";
    };

    nativeBuildInputs = [ p7zip ];
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/lib $out/bin

      7z -o$out/lib x ${src}

      cat >$out/bin/eduke32 <<EOF
      #!${runtimeShell}
      exec ${eduke32}/bin/eduke32 -j $out/lib $*
      EOF
      chmod +x $out/bin/eduke32
      ${(desktopItem "$out/bin/eduke32" " - Single Player").buildCommand}
    '';

    meta = with lib; {
      description = "TODO";
      homepage = "";
      license = licenses.unfree;
      platforms = platforms.linux;
      maintainers = with maintainers; [ yvesf ];
    };
  }
