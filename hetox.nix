{
  bendlas.machine = "hetox";
  imports = [
    # shared with ./base.nix
    ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix ./essential.module.nix
    # new base
    ./access.module.nix ./tmpfs.module.nix ./nginx.module.nix
    # gitlab / hdnews server
    ./hetox/configuration.nix
    ## TODO
    # ./nextcloud.module.nix
    # ./matrix-server.module.nix
  ];
  users.users.herwig.isNormalUser = true;
}
