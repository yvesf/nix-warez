{ config, pkgs, lib, ... }:
let 
  cfg = config.networking.firewall.rir-ip;
  rir-ip = pkgs.callPackage ./. {};
in {
  options.networking.firewall.rir-ip = {
    enable = lib.mkEnableOption "rir-ip country firewall";
    countries = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "ir" "ru" ];
      description = "list of two-letter country codes to block";
    };
  };
  config = lib.mkIf cfg.enable {
    networking.firewall.extraCommands = ''
      set -e
      BLOCKED=(${lib.concatStringsSep " " cfg.countries})
      D="${rir-ip}/share/rir-ip/country"
      echo "setup rules to block addresses of: ''${BLOCKED[*]}"

      ${pkgs.ipset}/bin/ipset restore -file <(
        echo "create blocklist4 hash:net family inet hashsize 4096 maxelem 65536 -exist"
        echo "flush blocklist4"
        for c in $BLOCKED; do
          sed -n -e 's/^\([^#].*\)/add blocklist4 \1 -exist/p' "$D/$c/ipv4-aggregated.txt"
        done

        echo "create blocklist6 hash:net family inet6 hashsize 4096 maxelem 65536 -exist"
        echo "flush blocklist6"
        for c in $BLOCKED; do
          sed -n -e 's/^\([^#].*\)/add blocklist6 \1 -exist/p' "$D/$c/ipv6-aggregated.txt"
        done
      )

      iptables -I nixos-fw -m set --match-set blocklist4 src -j nixos-fw-log-refuse
      ip6tables -I nixos-fw -m set --match-set blocklist6 src -j nixos-fw-log-refuse
    '';
  };
}
