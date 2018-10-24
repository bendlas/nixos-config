{ config, pkgs, ...}:
{

  boot = {
    consoleLogLevel = 7;
    extraTTYs = [ "ttyAMA0" ];
    kernelPackages = pkgs.linuxPackages_4_15;
    kernelParams = [
      "dwc_otg.lpm_enable=0"
      "console=ttyAMA0,115200"
      "rootwait"
      "elevator=deadline"
      "cma=32M"
    ];
    loader = {
      grub.enable = false;
      generationsDir.enable = false;
      raspberryPi = {
        enable = true;
	version = 3;
      };
    };
  };

  nix.buildCores = 4;

  nixpkgs.config.platform = lib.systems.platforms.aarch64;

  # cpufrequtils doesn't build on ARM
  powerManagement.enable = false;

  services.openssh.enable = true;

  hardware.enableRedistributableFirmware = true;
  hardware.firmware [
    (pkgs.stdenv.mkDerivation {
      name = "broadcom-rpi3-extra";
      src = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/54bab3d/brcm80211/brcm/brcmfmac43430-sdio.txt";
        sha256 = "19bmdd7w0xzybfassn7x4rb30l70vynnw3c80nlapna2k57xwbw7";
      };
      phases = [ "installPhase" ];
      installPhase = ''
        mkdir -p $out/lib/firmware/brcm
        cp $src $out/lib/firmware/brcm/brcmfmac43430-sdio.txt
      '';
    })
  ];
  networking.wireless.enable = true;

}
