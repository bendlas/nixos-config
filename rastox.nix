{
  bendlas.machine = "rastox";
  imports = [
    # shared with ./base.nix
    ./log.nix ./sources.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix
    # new base
    ./access.module.nix ./tmpfs.module.nix ./docu-disable.module.nix
    # mediacenter config
    ./rastox/configuration.nix
  ];
}
