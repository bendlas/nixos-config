# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/18121651-0c99-4b18-acda-11faf72e1f2f";
      fsType = "ext4";
    };

  fileSystems."/tmp" =
    { device = "TMP";
      fsType = "tmpfs";
      options = [ "size=16G" "mode=1777" ];
    };

  fileSystems."/var/tmp" =
    { device = "VARTMP";
      fsType = "tmpfs";
    };

  fileSystems."/boot/firmware" =
    { device = "/dev/disk/by-uuid/D449-45AA";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/af4a4349-3358-4a1d-b9e5-1de1c8989588"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
