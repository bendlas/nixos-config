{

  services.borgbackup.repos = {
    valheim-contox = {
      authorizedKeysAppendOnly = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKKsTTvCNGI1NDr25uh7/neFy9aED5g6xic0M/RA+EFe valheim@contox"
      ];
      path = "/var/borgbackup/valheim-contox";
    };
    herwig = {
      authorizedKeysAppendOnly = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/nw+URWOaWzJ3ZmT1BA2lKxGV0VyrOh9IbKF229kPw herwig@lenix"
      ];
      path = "/var/borgbackup/herwig";
      allowSubRepos = true;
    };
  };

}
