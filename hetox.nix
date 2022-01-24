{
  bendlas.machine = "hetox";
  imports = [
    # shared with ./base.nix
    ./log.nix ./sources.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix
    # gitlab / hdnews server
    ./hetox/configuration.nix
  ];
}
