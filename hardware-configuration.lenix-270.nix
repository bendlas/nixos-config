# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ # <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/cf7a2c05-5a08-4716-aa30-2c3556f5033c";
      fsType = "btrfs";
    };

  fileSystems."/tmp" =
    { device = "TMP";
      fsType = "tmpfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/D45C-9B25";
      fsType = "vfat";
    };

  fileSystems."/var/tmp" =
    { device = "VARTMP";
      fsType = "tmpfs";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/083e3aab-29cd-4d4c-a9b6-027c9b413af5"; }
    ];

  nix.maxJobs = lib.mkDefault 2;
  powerManagement.cpuFreqGovernor = "powersave";
}
