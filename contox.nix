{ config, lib, modulesPath, ... }:
{
  bendlas.machine = "contox";
  imports = [
    # shared with ./base.nix
    ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix ./essential.module.nix # ./convenient.module.nix
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
    encryption.mode = "none";
    startAt = []; ## disable timer, will be started by path watcher
    paths = [ "/var/lib/valheim/.config/unity3d/IronGate/Valheim/" ];
  };
  ## borg backup jobs get an implicit borgbackup-job-* prefix on systemd unit level
  ## thus this timer will trigger the backup job
  systemd.timers.borgbackup-job-valheim-contox = {
    description = "Backup delay timer for valheim server config and saves. Delays backup start in order to ensure that everything has been written properly";
    timerConfig.OnActiveSec = "10 seconds";
    timerConfig.AccuracySec = "1 seconds";
    ## stop timer after job completion, to re-prime for start
    timerConfig.RemainAfterElapse = false;
  };
  systemd.paths.borgbackup-job-valheim-contox = {
    description = "File watcher for valheim server config and saves";
    wantedBy = [ "multi-user.target" ];
    pathConfig.PathChanged = [
      "/var/lib/valheim/.config/unity3d/IronGate/Valheim"
      "/var/lib/valheim/.config/unity3d/IronGate/Valheim/worlds_local"
    ];
    ## trigger delay timer instead of service directly
    pathConfig.Unit = "borgbackup-job-valheim-contox.timer";
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
