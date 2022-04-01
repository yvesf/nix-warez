{ stdenv, lib, fetchFromGitHub, writeScript, python3 }:
let
  ip-deagg = writeScript "ipv6-deagg.py" ''
    #!${python3}/bin/python3
    import ipaddress, sys
    for line in sys.stdin.readlines():
      ipfrom, ipto, country = line.strip().split(",")
      ipfrom = ipaddress.ip_address(ipfrom)
      ipto = ipaddress.ip_address(ipto)
      for net in ipaddress.summarize_address_range(ipfrom, ipto):
        print("{},{}".format(net, country))
  '';
in stdenv.mkDerivation {
  name = "ip-country";
  version = "v20220331";

  src = fetchFromGitHub {
    owner = "sapics";
    repo = "ip-location-db";
    rev = "28086f45d8496e1112b475287ac9b7a0a3a680fe";
    sha256 = "sha256-IINlpMowXgsKiUtxnZ7l6/ZvqCQ+TvnoLd2v485avKA=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/ip-location-db/geo-whois-asn-country;

    cp $src/geo-whois-asn-country/geo-whois-asn-country-ipv4.csv \
      $out/share/ip-location-db/geo-whois-asn-country/ipv4.csv
    cp $src/geo-whois-asn-country/geo-whois-asn-country-ipv6.csv \
      $out/share/ip-location-db/geo-whois-asn-country/ipv6.csv

    echo "De-aggregate ipv4 nets"
    ${ip-deagg} < $out/share/ip-location-db/geo-whois-asn-country/ipv4.csv \
      > $out/share/ip-location-db/geo-whois-asn-country/ipv4-deagg.csv

    echo "De-aggregate ipv6 nets"
    ${ip-deagg} < $out/share/ip-location-db/geo-whois-asn-country/ipv6.csv \
      > $out/share/ip-location-db/geo-whois-asn-country/ipv6-deagg.csv
  '';

  meta = with lib; {
    description = "IP subnets grouped by country";
    homepage = "https://github.com/sapics/ip-location-db";
    license = licenses.cc0;
    platforms = platforms.all;
    maintainers = with maintainers; [ yvesf ];
  };
}
