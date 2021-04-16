{ writeScript, runCommand, requireFile, stdenv, lib, makeWrapper, makeDesktopItem
, unzip, wineFull, winetricks, python3, gtk3, gobject-introspection, python3Packages, ... }:
let
  data = runCommand "AoE2-FE-zip" {
    outputHashMode = "recursive";
    outputHash = "sha256-RK1p7T2b6MZlVITRTxAzJbGwSSdLGSfeVt3ckYguy24=";
    buildInputs = [ unzip ];
    src = requireFile {
      url = https://www.mysecretmirror.to/share/software/spiele/windows/Age%20of%20Empires%202/AoE2-FE.zip;
      name = "AoE2-FE.zip";
      sha256 = "1n3rl6xicfjx2xzgqawzixcayd9k0f37g9kmxyg5vd88nykrjjpa";
    };
  } ''unzip "$src" -d $out'';
  printResolution = writeScript "printResolution" ''
    #! /usr/bin/env python3
    import gi
    gi.require_version("Gdk", "3.0")
    from gi.repository import Gdk
    disp = Gdk.Display.get_default()
    rects = []
    for i in range(0,100):
      m = disp.get_monitor(i)
      if m:
        rects.append(m.get_geometry())
      else:
        break
    rects.sort(key=lambda g: g.height*g.width, reverse=True)
    print("RES_X={0.width}\nRES_Y={0.height}\nRES_X_BIN={0.width:08x}\nRES_Y_BIN={0.height:08x}".format(rects[0]))
  '';
  startup = writeScript "aoe2fe" ''
    set -x -e

    S=${data}/AoE2-FE
    export WINETRICKS_LATEST_VERSION_CHECK=disabled
    export WINEPREFIX=$(mktemp -d /tmp/wineprefix.XXXX)

    cleanup() {
    rm -rf "$WINEPREFIX"
    }
    trap cleanup EXIT

    pkill dplaysvr.exe || true # otherwise can't open new multiplayer if one is hanging

    eval $(printResolution)
    if [ -z "$RES_X" ]; then
      echo "printResolution failed"
      exit 1
    fi

    winetricks --unattended directplay
    winetricks --unattended vd=''${RES_X}x''${RES_Y}

    cd "$WINEPREFIX"/drive_c

    cat > temp.reg <<HERE
    Windows Registry Editor Version 5.00

    [HKEY_CURRENT_USER\Software\Microsoft\Microsoft Games\Age of Empires II: The Conquerors Expansion\1.0]
    "Advanced Buttons"=dword:00000002
    "Difficulty"=dword:00000004
    "Game Speed"=dword:0000000f
    "Graphics Detail Level"=dword:00000002
    "Mouse Style"=dword:00000002
    "MP Game Speed"=dword:0000000f
    "Music Volume"=dword:00001388
    "One Click Garrisoning"=dword:00000002
    "Rollover Text"=dword:00000001
    "Screen Height"=dword:$RES_Y_BIN
    "Screen Width"=dword:$RES_X_BIN
    "Scroll Speed"=dword:00000054
    "Sound Volume"=dword:00000000

    [HKEY_CURRENT_USER\Software\Microsoft\Microsoft Games\Age of Empires II: The Conquerors Expansion\1.0\EULA]
    "FIRSTRUN"=dword:00000001
    HERE

    regedit temp.reg

    cp -r -s "$S" .
    cd AoE2-FE

    find . -type d -exec chmod 755 \{\} \;

    # Make some stuff writeable
    for f in player.nfo Data/*.dat Data/*.Dat Data/shadow.col SaveGame Scenario Scenario AI Random; do
    rm -r "$f" && cp -r "$S/$f" "$f" && chmod -R 755 "$f"
    done

    wine age2_x1/age2_x2.exe
  '';
in stdenv.mkDerivation rec {
  name = "aoe2fe";
  desktopItem = makeDesktopItem {
    type = "Application";
    name = "aoe2fe";
    desktopName = "AoE2-FE";
    exec = "aoe2fe";
  };
  nativeBuildInputs = [
    makeWrapper
    gobject-introspection # for setup hook populating GI_TYPELIB_PATH
  ];
  buildInputs = [
    gtk3
    gobject-introspection
    python3Packages.setuptools
    python3Packages.pygobject3
  ];
  propagatedBuildInputs = [
    data
    wineFull
    winetricks
    python3
  ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin $out/lib

    ln -s ${startup} $out/bin/aoe2fe
    wrapProgram $out/bin/aoe2fe --prefix PATH : ${lib.makeBinPath propagatedBuildInputs}:$out/lib

    cp ${printResolution} $out/lib/printResolution
    wrapProgram $out/lib/printResolution --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
                                 --prefix PYTHONPATH : "$PYTHONPATH"
    ${desktopItem.buildCommand}
  '';
  meta = {
    description = "Age of Empires II HD – The Forgotten";
    license = lib.licenses.unfree;
  };
}



