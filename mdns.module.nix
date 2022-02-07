{

  require = [ ./name.module.nix ];

  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.addresses = true;
    nssmdns = true;
    wideArea = false;
    # extraServiceFiles.ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
  };

}
