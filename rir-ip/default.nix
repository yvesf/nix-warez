{ stdenv, lib, fetchFromGitHub }:
stdenv.mkDerivation {
  name = "rir-ip";
  version = "20220304-0532";

  src = fetchFromGitHub {
    owner = "ipverse";
    repo = "rir-ip";
    rev = "8db52fb874277d927c8364cc3ed783192c8e85d3";
    sha256 = "sha256-dVrdysLkZH393DVsvt2Da3N+yxpspOdi8URFCqlMa4I=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
      mkdir -p $out/share/rir-ip;
      cp -r $src/country/ $out/share/rir-ip/
  '';

  meta = with lib; {
    description = "IP subnets grouped by country";
    homepage = "https://github.com/ipverse/rir-ip";
    license = licenses.cc0;
    platforms = platforms.all;
    maintainers = with maintainers; [ yvesf ];
  };
}
