{ pkgs, ... }:
{
  bendlas.machine = "rastox";
  imports = [
    # shared with ./base.nix
    ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix ./essential.module.nix ./convenient.module.nix
    ./mdns.module.nix ./networkd.module.nix ./sound.module.nix
    # shared with ./desktop.nix
    ./desktop.essential.module.nix ./desktop.layout-us-gerextra.module.nix
    # new base
    ./access.module.nix ./tmpfs.module.nix ./docu-disable.module.nix
    # rastox specific
    <nixos-hardware/raspberry-pi/4>
    # Include the results of the hardware scan.
    ./rastox/hardware-configuration.nix
    # ./kodi-wayland.nix
    ./rastox/kodi-xorg.nix
    ./rastox/users.nix
    ./rastox/wifi.nix
    ./rastox/custom-tools.nix
    # ./rastox/video-rpi.nix

    {
      users.users.autossh = {
        isSystemUser = true;
        home = "/var/autossh";
        createHome = true;
        group = "autossh";
      };
      users.groups.autossh = {};
      services.autossh.sessions = [{
        extraArguments = "-N -R2201:localhost:22 hetox.bendlas.net";
        monitoringPort = 20000;
        name = "hetox-reverse-tunnel";
        user = "autossh";
      }];
    }
  ];

  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.autoSuspend = false;
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.murmur = {
    enable = true;
    openFirewall = true;
  };

  services.cron.enable = false;
  services.avahi.allowInterfaces = [ "end0" "wlan0" ];

  ## The global useDHCP flag is deprecated, therefore explicitly set to false here.
  ## Per-interface useDHCP will be mandatory in the future, so this generated config
  ## replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.end0.useDHCP = true;
  # networking.interfaces.wlan0.useDHCP = true;

  environment.systemPackages = with pkgs; [
    libraspberrypi raspberrypi-eeprom iw
    ungoogled-chromium-bendlas
  ];

  system.stateVersion = "21.11";

}

