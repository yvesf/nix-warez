{ config, pkgs, lib, ... }:
let
  cfg = config.networking.firewall.ipset-lists;
  ipsetHelper = pkgs.writeShellApplication {
    name = "ipset.sh";
    runtimeInputs = with pkgs; [ ipset wget ];
    text = builtins.readFile ./ipset.sh;
  };
in {
  options.networking.firewall.ipset-lists = {
    enable = lib.mkEnableOption "enable managed firewall ipset netsets";
  };
  config = lib.mkIf cfg.enable {
    systemd.timers.ipset-update = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:0/15";
        Unit = "ipset-update.service";
      };
    };
    systemd.services.ipset-update = {
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe ipsetHelper;
        Restart = "on-failure";
        RestartSec = 60;
      };
    };
    systemd.services.ipset-init = {
      wantedBy = [ "firewall.service" ];
      before = [ "firewall.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe ipsetHelper;
        Restart = "on-failure";
        RestartSec = 60;
      };
    };
  };
}
