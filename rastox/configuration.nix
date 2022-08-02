# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:
let
  cma = 512;
in {
  imports =
    [
      <nixos-hardware/raspberry-pi/4>
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ./kodi-wayland.nix
      ./kodi-xorg.nix
      ./desktop.nix
      ./users.nix
      ./wifi.nix
      # ./video-rpi.nix
    ];

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

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
  };
  hardware.raspberry-pi."4" = {
    fkms-3d = {
      enable = true;
      inherit cma;
    };
    audio.enable = true;
  };

  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  nix.settings.cores = 4;

  # nixpkgs.config.platform = lib.systems.platforms.aarch64-multiplatform;

  powerManagement.cpuFreqGovernor = "ondemand";
  services.cron.enable = false;

  services.avahi.interfaces = [ "eth0" "wlan0" ];

  # hardware.enableRedistributableFirmware = true;
  # hardware.firmware = [ pkgs.raspberrypifw ];
  # nixpkgs.overlays = [
  #   (self: super: {
  #     firmwareLinuxNonfree = super.firmwareLinuxNonfree.overrideAttrs (old: {
  #       version = "2021-10-04";
  #       src = pkgs.fetchgit {
  #         url = "https://github.com/RPi-Distro/firmware-nonfree.git";
  #         rev = "e1c6815a98377b87e30b599d214a6bae1a72bc77";
  #         sha256 = "1byla332p4dic5j1w08zynxp46sa4x7f99p03pcv80x7q51b5k7s";
  #       };
  #       outputHash = "1kkdz8dz8qjz79xg4b2q7y8w2cig2n11lgjnjm8z2ja911kqzil4";
  #     });
  #   })
  # ];

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.interfaces.wlan0.useDHCP = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    libraspberrypi raspberrypi-eeprom iw
    (pkgs.runCommand "custom-tools" {
      inherit (pkgs.stdenv) shell;
      inherit (pkgs) libraspberrypi tmux htop iftop;
    } ''
      mkdir -p $out/bin
      substituteAll ${./pistatus.in} $out/bin/pistatus
      substituteAll ${./server-monitor.in} $out/bin/server-monitor
      chmod -R +x $out/bin
    '')
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
