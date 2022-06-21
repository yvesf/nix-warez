{ stdenv, lib, fetchFromGitHub, writeScript, python3 }:
let
  ip-deagg = writeScript "ip-deagg.py" ''
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
  version = "v20220620";

  src = fetchFromGitHub {
    owner = "sapics";
    repo = "ip-location-db";
    rev = "7ea5d81e99ca629d989291d25ac8310aaa70860f";
    sha256 = "sha256-jLzmkQ9OMPoV7Ur4TZVbBLxXwu7vV102bEx8uz1U2ns=";
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
