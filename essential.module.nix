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
    tree file screen util-linux ent jq
    sysfsutils pciutils usbutils lshw lm_sensors
    psmisc htop btop lsof pv powertop
    # config.boot.kernelPackages.perf ## need to update mobile-nixos kernel for this
    inetutils netcat nmap traceroute socat rsync wget curl
    hdparm pmutils rlwrap which gnupg sqlite
    ed nano inotify-tools direnv pass libressl

    zip unzip lz4 xz gzip brotli bzip2 p7zip zstd

    git-new-workdir nix-du nix-tree
  ];

}
