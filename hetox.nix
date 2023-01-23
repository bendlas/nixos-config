{ pkgs, ... }:
{

  bendlas.machine = "hetox";
  imports = [
    ./hetox/hardware-configuration.nix ./hetox/borgbackup.nix
    ./hetox/gitlab.nix ./hetox/gitlab-lowmem.nix
    ## shared with ./base.nix
    ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix ./essential.module.nix # ./convenient.module.nix
    ## new base
    ./access.module.nix ./tmpfs.module.nix ./nginx.module.nix
    ## TODO
    # ./nextcloud.module.nix
    # ./matrix-server.module.nix
    {
      users.users.autossh = {
        isSystemUser = true;
        openssh.authorizedKeys.keys = [
          "command=\"/usr/bin/env false\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKJbkyXIY5eI+G+uK60Hensh+EmpMithyDhWQSvNOv58 autossh@rastox"
          "command=\"/usr/bin/env false\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINydu//Or1ch82XHgguSuRvlaLx+yhj6/N4BAdU0Rdj0 autossh@jellydeck"
        ];
        group = "autossh";
      };
      users.groups.autossh = {};
    }
  ];

  users.users.herwig.isNormalUser = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.devices = [ "/dev/sda" ];
  networking.hostName = "hetox"; # Define your hostname.
  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;
  networking.nat.externalInterface = "ens3";

  environment.systemPackages = with pkgs; [
    # emacsBendlasNox
    emacs-nox
  ];

  system.stateVersion = "21.05"; # Did you read the comment?

}
