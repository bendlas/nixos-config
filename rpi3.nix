{ lib, config, pkgs, ...}:
{
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
  ];
  sdImage.firmwareSize = 128;
  boot = {
    consoleLogLevel = 7;
    # extraTTYs = [ "ttyAMA0" ];
    kernelPackages = pkgs.linuxPackages_5_10;
    kernelParams = lib.mkForce [
      # "dwc_otg.lpm_enable=0"
      # "console=ttyAMA0,115200"
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
        firmwareConfig = ''
          dtparam=audio=on
        '';
        uboot.enable = true;
      };
      # generic-extlinux-compatible.enable = true;
    };
    initrd.kernelModules = [ "vc4" "bcm2835_dma" "i2c_bcm2835" ];
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  nix.settings.cores = 4;

  nixpkgs.config.platform = lib.systems.platforms.aarch64-multiplatform;

  # cpufrequtils doesn't build on ARM
  # powerManagement.enable = false;

  services.openssh.enable = true;
  services.cron.enable = false;

  networking.wireless.enable = true;

  hardware.enableRedistributableFirmware = true;
  # hardware.firmware = [
  #   (pkgs.stdenv.mkDerivation {
  #     name = "broadcom-rpi3-extra";
  #     src = pkgs.fetchurl {
  #       url = "https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/54bab3d/brcm80211/brcm/brcmfmac43430-sdio.txt";
  #       sha256 = "19bmdd7w0xzybfassn7x4rb30l70vynnw3c80nlapna2k57xwbw7";
  #     };
  #     phases = [ "installPhase" ];
  #     installPhase = ''
  #       mkdir -p $out/lib/firmware/brcm
  #       cp $src $out/lib/firmware/brcm/brcmfmac43430-sdio.txt
  #     '';
  #   })
  # ];
  nixpkgs.overlays = [
    (self: super: {
      firmwareLinuxNonfree = super.firmwareLinuxNonfree.overrideAttrs (old: {
        version = "2021-10-04";
        src = pkgs.fetchgit {
          url = "https://github.com/RPi-Distro/firmware-nonfree.git";
          rev = "e1c6815a98377b87e30b599d214a6bae1a72bc77";
          sha256 = "1byla332p4dic5j1w08zynxp46sa4x7f99p03pcv80x7q51b5k7s";
        };
        outputHash = "1kkdz8dz8qjz79xg4b2q7y8w2cig2n11lgjnjm8z2ja911kqzil4";
      });
    })
  ];

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC70QgW3EnX781iFOlojPnwST1CiMZaWdQEJNgSbsvaEFeHwFNDr9Ma2kTzjFQnpLKfb7eAr7BsUX3uSJjFq6MDTfgynCSXtgOxaahTfoVFFvJdGZPtXU09k7xSW043A7Ziwi8iPM0EFKUb85W6v4S1VACpjD57SEs4enUsyrXO8XVBDpqRQLdPDXjyNqzZ0zafbs22bDYDUmgr3UTItSzrGG7fzPyP3D2cJ1HKptQNUBRwjMvduG5by+ONxtuNJ7XGtQfFOyLJl4QFCWCSNwVEzv0CqAfrbq3XmqsAMXZJeMNo0OG/XpgQT2W4oP0QcyW9hHvxe6S34DjXDCaN8SreTJqq/8n3gQIj2/bkW9gGOHceZ98BDVXAeVXQj4opd3qF1V3DkP7NhUZEpgqHZglpkmcZqiufpdJbhnbjjIAUPN9c2dpEKWiR+UTR0hUedERDEGge6caM0XpfKPDiFXQpNgMBhatRkp9iNwoCIbp1muzYZpiu8YFNFbZmRmXcW8o8b3/MoEWZZTvMcffk7Yk+K0lItLmR7wjAJVZXM/7CbP6bVECbYAGNaQ50ZlPgt1wAU9VoE9oV3U2bVmV6Vdic1w1LS3pCOT9DNOXkGvbxLxp/gwJVFwkHVBAHnSLCyRyNn3GL+rzPO0Mzej2Q9stPUExcoMBkm6e4pUatynHONw== herwig@lenotox"
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

}
