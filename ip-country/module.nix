{ config, pkgs, lib, ... }:
let
  cfg = config.networking.firewall.ip-country;
  ip-country = pkgs.callPackage ./. { };
in {
  options.networking.firewall.ip-country = {
    enable = lib.mkEnableOption "ip-country firewall";
    countries = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "DE" "FR" "AT" "IT" "GB" "RS" ];
      description = "list of upper two-letter country codes to allow";
    };
  };
  config = lib.mkIf cfg.enable {
    networking.firewall.extraCommands = ''
      set -e
      ALLOWED="${lib.concatStringsSep "\\|" cfg.countries}"
      D="${ip-country}/share/ip-location-db/geo-whois-asn-country"
      echo "setup rules to block addresses of: ''${ALLOWED[*]}"

      size_v4=$(sed -n -e "s/\(.\+\),\($ALLOWED\)/&/p" "$D/ipv4-deagg.csv" | wc -l)
      size_v6=$(sed -n -e "s/\(.\+\),\($ALLOWED\)/&/p" "$D/ipv6-deagg.csv" | wc -l)
      
      ${pkgs.ipset}/bin/ipset destroy '-!' allowlist4
      ${pkgs.ipset}/bin/ipset destroy '-!' allowlist6
      ${pkgs.ipset}/bin/ipset restore -file <(
        echo "create allowlist4 hash:net family inet hashsize $size_v4 maxelem $size_v4"
        echo "flush allowlist4"
        sed -n -e "s/\(.\+\),\($ALLOWED\)/add allowlist4 \1 -exist/p" "$D/ipv4-deagg.csv"

        echo "create allowlist6 hash:net family inet6 hashsize $size_v6 maxelem $size_v6"
        echo "flush allowlist6"
        sed -n -e "s/\(.\+\),\($ALLOWED\)/add allowlist6 \1 -exist/p" "$D/ipv6-deagg.csv"
      )

      ${pkgs.iptables}/bin/iptables -F nixos-fw-accept
      ${pkgs.iptables}/bin/iptables -A nixos-fw-accept -i lo -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A nixos-fw-accept -m set --match-set allowlist4 src -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A nixos-fw-accept -j REJECT
    
      ${pkgs.iptables}/bin/ip6tables -F nixos-fw-accept
      ${pkgs.iptables}/bin/ip6tables -A nixos-fw-accept -i lo -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -A nixos-fw-accept -s fe80::/64 -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -I nixos-fw-accept -m set --match-set allowlist6 src -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -A nixos-fw-accept -j REJECT
    '';
  };
}
