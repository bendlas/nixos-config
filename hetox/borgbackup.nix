{

  services.borgbackup.repos = {
    valheim-contox = {
      authorizedKeysAppendOnly = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKKsTTvCNGI1NDr25uh7/neFy9aED5g6xic0M/RA+EFe valheim@contox"
      ];
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfZYoqHjtHqoJPk3ZhDVX6w/Tg49FqF5XTaOWRqYtSq herwig@lenix"
      ];
      path = "/var/borgbackup/valheim-contox";
    };
    herwig = {
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfZYoqHjtHqoJPk3ZhDVX6w/Tg49FqF5XTaOWRqYtSq herwig@lenix"
      ];
      path = "/var/borgbackup/herwig";
      allowSubRepos = true;
    };
  };

}
