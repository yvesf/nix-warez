{ pkgs ? import <nixpkgs> {}, ... }:
let 
   tpLightBell = pkgs.writeCBin "tpLightBell" ''
      #include <unistd.h>
      #include <fcntl.h>
      int main() {
        int fd = open("/sys/devices/platform/thinkpad_acpi/leds/tpacpi::kbd_backlight/brightness", O_WRONLY);
        if (fd > 0) {
          (void) write(fd, "2\n", 2);
          usleep(600000);
          (void) write(fd, "0\n", 2);
          close(fd);
        }
      }
    '';
in
  pkgs.stdenv.mkDerivation {
    name = "tpLightBell";
    phases = [ "installPhase" "fixupPhase" ];
    installPhase = ''
      install -D -t $out/bin ${tpLightBell}/bin/tpLightBell
    '';
  }
