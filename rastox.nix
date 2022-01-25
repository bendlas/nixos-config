{
  bendlas.machine = "rastox";
  imports = [
    # shared with ./base.nix
    ./log.nix ./sources.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix
    # mediacenter config
    ./rastox/configuration.nix
  ];
}