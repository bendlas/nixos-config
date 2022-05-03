{ config, lib, modulesPath, ... }:
{
  bendlas.machine = "contox";
  imports = [
    # shared with ./base.nix
    ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix ./essential.module.nix
    # new base
    ./access.module.nix ./tmpfs.module.nix
    # code server
    ./code-server.module.nix
    # contox
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  users.users.herwig.isNormalUser = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  hardware.enableRedistributableFirmware = true;

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  system.stateVersion = "21.11";


  # hardware-configuration.nix
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b79e2820-7c20-40e3-b1b5-9019df8b5560";
    fsType = "xfs";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/ed4fd16e-5f50-41aa-8501-da7a6acf193a"; }
  ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
