{ ... }:
{
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    startWhenNeeded = true;
  };
  services.fail2ban = {
    enable = true;
    jails = {
      # this is predefined
      ssh-iptables = ''
        enabled  = true
      '';
    };
  };
  programs.mosh.enable = true;
  programs.ssh.setXAuthLocation = true;
}
