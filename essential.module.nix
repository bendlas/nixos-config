{ pkgs, config, ... }:

{

  programs.tmux = {
    enable = true;
    secureSocket = false; # survive user logout
    historyLimit = 10000;
  };

  programs.git.enable = true;
  programs.iftop.enable = true;
  programs.iotop.enable = true;
  programs.gnupg.agent.enable = true;

  environment.systemPackages = with pkgs; [
    tree file screen utillinux ent jq
    systool pciutils usbutils lshw lm_sensors
    psmisc htop btop lsof pv powertop
    config.boot.kernelPackages.perf
    telnet netcat nmap traceroute socat rsync wget curl
    hdparm pmutils rlwrap which gnupg sqlite
    ed nano inotify-tools direnv pass libressl

    zip unzip lz4 xz gzip rar unrar
  ];

}
