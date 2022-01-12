{ config, pkgs, lib, ... }:

{ ## Outsource nixpkgs.config to be shared with nix-env
  require = [ ./desktop.nix ./hardware-configuration.schentox.nix ./dev.nix ]; # ./power-savings.nix

  environment.systemPackages = (with pkgs; [
    bluez5
  ]);

  boot = {
    initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "firewire_ohci" "usb_storage" ];
    kernelModules = [ "kvm-intel" ];
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };
    kernelParams = [ "resume=UUID=d71e0b01-5042-4456-8a72-d4653d0b7e4e" ];
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/da948a98-1b1b-4c06-98c9-1147173448ee";
      fsType = "ext4";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/0d892680-934c-437f-8ede-a42ef781c835";
      fsType = "ext4";
    };

  fileSystems."/tmp" =
    { device = "tmp";
      fsType = "tmpfs";
      options = [ "size=8g" "mode=1777" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/d71e0b01-5042-4456-8a72-d4653d0b7e4e"; }
    ];

  networking = rec {
    hostName = "schentox";
    hostId = "99cfb55e";
    nat.externalInterface = "wlp3s0";
    wireless = {
      enable = true;
      userControlled.enable = true;
    };
  };

  services = {
    xserver = {
      videoDrivers = [ "nouveau" "vesa" ];
    };
    printing = {
      enable = true;
      drivers = [ pkgs.splix ];
    };
    udev.extraRules = ''
      ATTR{idvendor}=="04e8", ATTR{idProduct}=="344f", MODE:="0660", GROUP:="lp", ENV{libsane_matched}:="yes"
    '';
    i2p.enable = lib.mkForce false;
    tor.enable = lib.mkForce false;
  };

  hardware = {
    trackpoint.emulateWheel = true;
    bluetooth.enable = true;
    sane.enable = true;
  };

  users.extraUsers = {
    "augustine" = {
      description = "Augustine Hochleitner";
      isNormalUser = true;
      extraGroups = [ "networkmanager" ];
    };
    "dorothea" = {
      description = "Dorothea Hochleitner";
      isNormalUser = true;
      extraGroups = [ "networkmanager" ];
    };
  };

  nix.maxJobs = 2;

}
