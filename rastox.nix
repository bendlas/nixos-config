{
  bendlas.machine = "rastox";
  imports = [
    # shared with ./base.nix
    ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix ./essential.module.nix ./convenient.module.nix
    ./mdns.module.nix ./networkd.module.nix
    # new base
    ./access.module.nix ./tmpfs.module.nix ./docu-disable.module.nix
    # mediacenter config
    ./rastox/configuration.nix
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

}

