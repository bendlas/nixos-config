{ config, lib, ... }:
{
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
  } // (
    if "stable" == config.bendlas.stability
    then {
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
      forwardX11 = true;
    } else {
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = true;
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
