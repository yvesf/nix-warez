{ qt5 , kdeFrameworks
, lib , fetchurl , stdenv , pkg-config , ... }:

qt5.mkDerivationWith stdenv.mkDerivation rec {
  pname = "qelectrotech";
  version = "0.8.0";

  src = fetchurl {
    url = "https://git.tuxfamily.org/qet/qet.git/snapshot/qet-${version}.tar.gz";
    sha256 = "sha256-Yupb002CPC0of6WNuLdFKCXXw0ebjOtmUO9jDDl24HA=";
  };

  postPatch = ''
    sed -i -e 's/GIT_COMMIT_SHA.*/GIT_COMMIT_SHA="\\\\\\"${version}\\\\\\""/' qelectrotech.pro
    sed -i -e 's/^ *COMPIL_PREFIX.*//' qelectrotech.pro
    sed -i -e 's/^ *INSTALL_PREFIX.*//' qelectrotech.pro
  '';

  qmakeFlags = [
    "INSTALL_ROOT=${placeholder "out"}/"
    "COMPIL_PREFIX=${placeholder "out"}/"
    "INSTALL_PREFIX=${placeholder "out"}/"
  ];

  buildInputs = [
    kdeFrameworks.kcoreaddons
    kdeFrameworks.kwidgetsaddons
    qt5.qtbase
    qt5.qtsvg
  ];

  nativeBuildInputs = [
    qt5.qmake
    qt5.qttools
    pkg-config
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "QElectroTech is a free software to create electric diagrams";
    homepage = "https://qelectrotech.org/";
    license = licenses.gpl2;
    maintainers = with maintainers; [ yvesf ];
    platforms = qt5.qtbase.meta.platforms;
  };
}

