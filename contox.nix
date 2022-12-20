{ config, lib, modulesPath, ... }:
{
  bendlas.machine = "contox";
  imports = [
    # shared with ./base.nix
    ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix ./essential.module.nix ./convenient.module.nix
    # new base
    ./access.module.nix ./tmpfs.module.nix ./nginx.module.nix
    # servers
    ./code-server.module.nix
    ./factorio-server.module.nix
    ./valheim-server.module.nix
    # contox
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  services.valheim-server.password = builtins.readFile /etc/secrets/valheim-server-password;
  services.borgbackup.jobs.valheim-contox = {
    user = "valheim";
    repo = "borg@hetox.bendlas.net:.";
    compression = "auto,zstd";
    startAt = []; ## disable timer, will be started by path watcher
    paths = [ "/var/lib/valheim/.config/unity3d/IronGate/Valheim/" ];
  };
  ## timer for delaying backup after path change
  systemd.timers.borgbackup-job-valheim-contox = {
    timerConfig.OnActiveSec = "10 seconds";
    timerConfig.AccuracySec = "1 seconds";
  };
  systemd.paths.borgbackup-job-valheim-contox = {
    wantedBy = [ "multi-user.target" ];
    pathConfig.PathChanged = "/var/lib/valheim/.config/unity3d/IronGate/Valheim";
  };

  ## web
  # services.nginx.enable = lib.mkForce false;
  # security.acme.defaults.email = "herwig@bendlas.net";
  # security.acme.acceptTerms = true;

  ## contox main
  users.users.herwig.isNormalUser = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  hardware.enableRedistributableFirmware = true;

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  system.stateVersion = "21.11";

  ## hardware-configuration.nix
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
