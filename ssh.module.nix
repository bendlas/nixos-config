{ config, lib, ... }:
{
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    forwardX11 = true;
  } // (
    if "stable" == config.bendlas.stability
    then {
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
    } else {
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    }
  );
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
