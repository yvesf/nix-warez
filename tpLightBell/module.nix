{ config, pkgs, lib, ... }:
let 
  tpLightBell = pkgs.callPackage ./. {};
  cfg = config.programs.tpLightBell;
in {
  options.programs.tpLightBell = {
    enable = lib.mkEnableOption "Bell";
    name = lib.mkOption {
      type = lib.types.str;
      default = "tpBell";
    };
  };
  config = lib.mkIf cfg.enable {
    security.wrappers."${cfg.name}".source = "${tpLightBell}/bin/tpLightBell";
  };
}
