{ config, pkgs, lib, ... }:
let
  cfg = config.networking.firewall.ip-country;
  ip-country = pkgs.callPackage ./. { };
in {
  options.networking.firewall.ip-country = {
    enable = lib.mkEnableOption "ip-country firewall";
    countries = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "DE" "FR" "AT" "CH" "IT" "GB" "RS" ];
      description = ''
        list of upper two-letter country codes for which to add ip-addresses to allowlist4/allowlist6 ipset

        Usage example:
        > iptables -A nixos-fw-accept -m set --match-set allowlist4 src -j ACCEPT
        > ip6tables -I nixos-fw-accept -m set --match-set allowlist6 src -j ACCEPT
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.ip-country = {
      wantedBy = [ "firewall.service" ];
      before = [ "firewall.service" ];
      path = with pkgs; [ ipset iptables ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "ip-country-start" ''
          set -o errexit -o pipefail -o nounset
          shopt -s inherit_errexit
          
          ALLOWED="${lib.concatStringsSep "\\|" cfg.countries}"
          D="${ip-country}/share/ip-location-db/geo-whois-asn-country"
          echo "setup rules to block addresses of: ''${ALLOWED[*]}"

          size_v4=$(sed -n -e "s/\(.\+\),\($ALLOWED\)/&/p" "$D/ipv4-deagg.csv" | wc -l)
          size_v6=$(sed -n -e "s/\(.\+\),\($ALLOWED\)/&/p" "$D/ipv6-deagg.csv" | wc -l)
          ipset -exist flush allowlist4 || true
          ipset -exist flush allowlist6 || true
          
          ${pkgs.ipset}/bin/ipset restore -file <(
            echo "create allowlist4 hash:net family inet hashsize $size_v4 maxelem $size_v4"
            echo "flush allowlist4"
            sed -n -e "s/\(.\+\),\($ALLOWED\)/add allowlist4 \1 -exist/p" "$D/ipv4-deagg.csv"

            echo "create allowlist6 hash:net family inet6 hashsize $size_v6 maxelem $size_v6"
            echo "flush allowlist6"
            sed -n -e "s/\(.\+\),\($ALLOWED\)/add allowlist6 \1 -exist/p" "$D/ipv6-deagg.csv"
          )
        '';

        ExecStop = pkgs.writeShellScript "ip-country-start" ''
          set -o errexit -o pipefail -o nounset
          shopt -s inherit_errexit
          
          ipset destroy '-!' allowlist4
          ipset destroy '-!' allowlist6
        '';
        Restart = "on-failure";
        RestartSec = 60;
      };
    };
  };
}
