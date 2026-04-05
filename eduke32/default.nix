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
      url = "https://dukeworld.com/eduke32/synthesis/latest/eduke32_win32_20260203-10664-ba6b7bb1d.7z";
      hash = "sha256-GEJAO3ZpvSuOBJ+fQBbjMtbq2siyTvwaqxSAAheDkao=";
    };
    grp = fetchurl {
      url = "https://github.com/ninjada/eduke32/raw/refs/heads/master/duke3d.grp";
      hash = "sha256-iaYKomMzvWWamqGv93Zm4GHaZDFzSaanQsHZJ1SDbyw=";
    };

    nativeBuildInputs = [ p7zip ];
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/lib $out/bin

      7z -o$out/lib x ${src}

      cp ${grp} $out/lib/

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
