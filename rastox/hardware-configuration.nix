{ config, lib, pkgs, modulesPath, ... }:

let
  cma = 512;
in {

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/18121651-0c99-4b18-acda-11faf72e1f2f";
      fsType = "ext4";
    };

  fileSystems."/boot/firmware" =
    { device = "/dev/disk/by-uuid/D449-45AA";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/af4a4349-3358-4a1d-b9e5-1de1c8989588"; }
    ];

  powerManagement.cpuFreqGovernor = "ondemand";
  nix.settings.cores = 4;

  boot = {
    consoleLogLevel = 7;
    kernelPackages = pkgs.linuxPackages_rpi4;
    kernelParams = [
      # "dwc_otg.lpm_enable=0"
      # "console=ttyAMA0,115200"
      "rootwait"
      # "elevator=deadline"
      "cma=${toString cma}M"
      "usbhid.mousepoll=0"
    ];
    loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
      ## just disable raspi firmware generation, for now. Please
      ## update firmwareConfig yourself
      raspberryPi = {
        enable = false;
        version = 4;
        ## https://github.com/NixOS/nixpkgs/pull/67902#discussion_r744178864
        # firmwareDir = "/boot/firmware";
        firmwareConfig = ''
          [pi3]
          kernel=u-boot-rpi3.bin

          [pi4]
          kernel=u-boot-rpi4.bin
          enable_gic=1
          armstub=armstub8-gic.bin

          # Otherwise the resolution will be weird in most cases, compared to
          # what the pi3 firmware does by default.
          disable_overscan=1

          [all]
          # Boot in 64-bit mode.
          arm_64bit=1

          # U-Boot needs this to work, regardless of whether UART is actually used or not.
          # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
          # a requirement in the future.
          enable_uart=1

          # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
          # when attempting to show low-voltage or overtemperature warnings.
          avoid_warnings=1

          # Boost to 1.8GHz if safe
          arm_boost=1

          # hdmi_drive=2
          # hdmi_group=1
          # dtoverlay=vc4-fkms-v3d
          # dtoverlay=vc4-kms-v3d-pi4
          # max_framebuffers=2
          # dtparam=audio=on
        '';
        uboot.enable = true;
      };
    };
  };
  hardware.raspberry-pi."4" = {
    fkms-3d = {
      enable = true;
      inherit cma;
    };
    audio.enable = true;
  };

}
