{ config, ... }:
{
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    # "${if "stable" == config.bendlas.stability
    #    then "challengeResponseAuthentication"
    #    else "kbdInteractiveAuthentication"}" = false;
    startWhenNeeded = true;
    forwardX11 = true;
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
