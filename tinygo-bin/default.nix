{ lib, stdenv, fetchurl, buildFHSUserEnv, ... }:
let
  tinygo-bin = stdenv.mkDerivation rec {
    name = "tinygo-bin-${version}";
    version = "0.17.0";

    src = fetchurl {
      url = "https://github.com/tinygo-org/tinygo/releases/download/v${version}/tinygo${version}.linux-amd64.tar.gz";
      sha256 = "sha256-7Yk745c3ahN8Q0Mli8Z7v1G5I6UbVKYva0zrzqFRFEI=";
    };

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir $out
      tar --strip-components=1 --directory=$out -xzpf ${src}
    '';

    meta = with lib; {
      homepage = "https://tinygo.org/";
      description = "Go compiler for small places (binary package)";
      license = licenses.bsd3;
      platforms = platforms.linux;
      maintainers = with maintainers; [ yvesf ];
    };
  };
in
  buildFHSUserEnv rec {
    name = "tinygo";
    runScript = "${tinygo-bin}/bin/tinygo";
    targetPkgs = pkgs: [ pkgs.go_1_15 ]; 
  }

