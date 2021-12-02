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
      ./networkd.nix
      ./wifi.nix
      # ./video-rpi.nix
    ];

  boot = {
    consoleLogLevel = 7;
    # extraTTYs = [ "ttyAMA0" ];
    # kernelPackages = pkgs.linuxPackages_5_10;
    kernelPackages = pkgs.linuxPackages_rpi4;
    kernelParams = [
      # "dwc_otg.lpm_enable=0"
      # "console=ttyAMA0,115200"
      "rootwait"
      # "elevator=deadline"
      "cma=${toString cma}M"
      "usbhid.mousepoll=0"
    ];
    tmpOnTmpfs = true;
    loader = {
      grub.enable = false;
      # generationsDir.enable = false;
      raspberryPi = {
        enable = true;
	      version = 4;
        ## FIXME: right now, this needs a manual update
        ## https://github.com/NixOS/nixpkgs/pull/67902#discussion_r744178864
        firmwareConfig = ''
          # hdmi_drive=2
          # hdmi_group=1
          # dtoverlay=vc4-fkms-v3d
          # max_framebuffers=2
          # dtparam=audio=on
        '';
        uboot.enable = true;
      };
      generic-extlinux-compatible.enable = true;
    };
    # initrd.kernelModules = [ "vc4" "bcm2835_dma" "i2c_bcm2835" ];
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

  nix.buildCores = 4;

  # nixpkgs.config.platform = lib.systems.platforms.aarch64-multiplatform;

  powerManagement.cpuFreqGovernor = "ondemand";
  programs.mosh.enable = true;
  services.openssh.enable = true;
  services.cron.enable = false;
  services.avahi = {
    publish.enable = true;
    publish.addresses = true;
    # publish.workstation = true;
    enable = true;
    nssmdns = true;
    wideArea = false;
    # extraServiceFiles.ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
  };

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ pkgs.raspberrypifw ];
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

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC70QgW3EnX781iFOlojPnwST1CiMZaWdQEJNgSbsvaEFeHwFNDr9Ma2kTzjFQnpLKfb7eAr7BsUX3uSJjFq6MDTfgynCSXtgOxaahTfoVFFvJdGZPtXU09k7xSW043A7Ziwi8iPM0EFKUb85W6v4S1VACpjD57SEs4enUsyrXO8XVBDpqRQLdPDXjyNqzZ0zafbs22bDYDUmgr3UTItSzrGG7fzPyP3D2cJ1HKptQNUBRwjMvduG5by+ONxtuNJ7XGtQfFOyLJl4QFCWCSNwVEzv0CqAfrbq3XmqsAMXZJeMNo0OG/XpgQT2W4oP0QcyW9hHvxe6S34DjXDCaN8SreTJqq/8n3gQIj2/bkW9gGOHceZ98BDVXAeVXQj4opd3qF1V3DkP7NhUZEpgqHZglpkmcZqiufpdJbhnbjjIAUPN9c2dpEKWiR+UTR0hUedERDEGge6caM0XpfKPDiFXQpNgMBhatRkp9iNwoCIbp1muzYZpiu8YFNFbZmRmXcW8o8b3/MoEWZZTvMcffk7Yk+K0lItLmR7wjAJVZXM/7CbP6bVECbYAGNaQ50ZlPgt1wAU9VoE9oV3U2bVmV6Vdic1w1LS3pCOT9DNOXkGvbxLxp/gwJVFwkHVBAHnSLCyRyNn3GL+rzPO0Mzej2Q9stPUExcoMBkm6e4pUatynHONw== herwig@lenotox"
  ];

  networking.hostName = "rastox"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.interfaces.wlan0.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  programs.tmux.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    libraspberrypi tree tmux htop iftop raspberrypi-eeprom
    systool usbutils git iw btop iotop lsof
    config.boot.kernelPackages.perf
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
