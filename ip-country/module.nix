{ config, pkgs, lib, ... }:
let
  cfg = config.networking.firewall.ip-country;
  ip-country = pkgs.callPackage ./. { };
in {
  options.networking.firewall.ip-country = {
    enable = lib.mkEnableOption "ip-country firewall";
    countries = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "IR" "RU" ];
      description = "list of upper two-letter country codes to block";
    };
  };
  config = lib.mkIf cfg.enable {
    networking.firewall.extraCommands = ''
      set -e
      BLOCKED="${lib.concatStringsSep "\\|" cfg.countries}"
      D="${ip-country}/share/ip-location-db/geo-whois-asn-country"
      echo "setup rules to block addresses of: ''${BLOCKED[*]}"

      ${pkgs.ipset}/bin/ipset restore -file <(
        echo "create blocklist4 hash:net family inet hashsize 4096 maxelem 65536 -exist"
        echo "flush blocklist4"
        sed -n -e "s/\(.\+\),\($BLOCKED\)/add blocklist4 \1 -exist/p" "$D/ipv4-deagg.csv"

        echo "create blocklist6 hash:net family inet6 hashsize 4096 maxelem 65536 -exist"
        echo "flush blocklist6"
        sed -n -e "s/\(.\+\),\($BLOCKED\)/add blocklist6 \1 -exist/p" "$D/ipv6-deagg.csv"
      )

      ${pkgs.iptables}/bin/iptables -I nixos-fw -m set --match-set blocklist4 src -j nixos-fw-log-refuse
      ${pkgs.iptables}/bin/ip6tables -I nixos-fw -m set --match-set blocklist6 src -j nixos-fw-log-refuse
    '';
  };
}
