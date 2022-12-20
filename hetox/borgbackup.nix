{

  services.borgbackup.repos = {
    valheim-contox = {
      authorizedKeysAppendOnly = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKKsTTvCNGI1NDr25uh7/neFy9aED5g6xic0M/RA+EFe valheim@contox"
      ];
      path = "/var/borgbackup/valheim-contox";
    };
  };

}
