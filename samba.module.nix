{
networking.firewall.allowPing = true;
services.samba = {
  enable = true;
  openFirewall = true;
  securityType = "user";
  extraConfig = ''
    workgroup = WORKGROUP
    server string = natox
    netbios name = natox
    security = user 
    #use sendfile = yes
    min protocol = smb2
    #hosts allow = 192.168.0.0/24  localhost
    #hosts deny = 0.0.0.0/0
    guest account = nobody
    map to guest = bad user
  '';
  shares = {
    nara = {
      path = "/var/lib/Share";
      browseable = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      # "force user" = "nara";
      # "force group" = "users";
      "valid users" = "nara";
      public = "no";
      writeable = "yes";
      "fruit:aapl" = "yes";
      "fruit:time machine" = "yes";
      "vfs objects" = "fruit streams_xattr";
      "ea support" = "yes";
    };
  };
};
}