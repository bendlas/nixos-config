# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  # boot.loader.grub.enable = true;
  # boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "nodev"; # or "nodev" for efi only

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.tmpOnTmpfs = true;
  boot.kernelParams = [ "amd_iommu=on" ];

  networking.hostName = "natox"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp9s0.useDHCP = true;
  networking.interfaces.wlp8s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_AT.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  # Enable sound.
  sound.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups = {
    steam = { };
  };
  users.users = {
    nara = {
      description = "Nara Richter";
      isNormalUser = true;
      extraGroups = [ "wheel" "steam" "libvirtd" "kvm" "qemu-libvirtd" ];
    };
    herwig = {
      description = "Herwig Hochleitner";
      isNormalUser = true;
      extraGroups = [ "wheel" "steam" "libvirtd" "kvm" "qemu-libvirtd" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC70QgW3EnX781iFOlojPnwST1CiMZaWdQEJNgSbsvaEFeHwFNDr9Ma2kTzjFQnpLKfb7eAr7BsUX3uSJjFq6MDTfgynCSXtgOxaahTfoVFFvJdGZPtXU09k7xSW043A7Ziwi8iPM0EFKUb85W6v4S1VACpjD57SEs4enUsyrXO8XVBDpqRQLdPDXjyNqzZ0zafbs22bDYDUmgr3UTItSzrGG7fzPyP3D2cJ1HKptQNUBRwjMvduG5by+ONxtuNJ7XGtQfFOyLJl4QFCWCSNwVEzv0CqAfrbq3XmqsAMXZJeMNo0OG/XpgQT2W4oP0QcyW9hHvxe6S34DjXDCaN8SreTJqq/8n3gQIj2/bkW9gGOHceZ98BDVXAeVXQj4opd3qF1V3DkP7NhUZEpgqHZglpkmcZqiufpdJbhnbjjIAUPN9c2dpEKWiR+UTR0hUedERDEGge6caM0XpfKPDiFXQpNgMBhatRkp9iNwoCIbp1muzYZpiu8YFNFbZmRmXcW8o8b3/MoEWZZTvMcffk7Yk+K0lItLmR7wjAJVZXM/7CbP6bVECbYAGNaQ50ZlPgt1wAU9VoE9oV3U2bVmV6Vdic1w1LS3pCOT9DNOXkGvbxLxp/gwJVFwkHVBAHnSLCyRyNn3GL+rzPO0Mzej2Q9stPUExcoMBkm6e4pUatynHONw== herwig@lenotox"
      ];
    };
    root.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC70QgW3EnX781iFOlojPnwST1CiMZaWdQEJNgSbsvaEFeHwFNDr9Ma2kTzjFQnpLKfb7eAr7BsUX3uSJjFq6MDTfgynCSXtgOxaahTfoVFFvJdGZPtXU09k7xSW043A7Ziwi8iPM0EFKUb85W6v4S1VACpjD57SEs4enUsyrXO8XVBDpqRQLdPDXjyNqzZ0zafbs22bDYDUmgr3UTItSzrGG7fzPyP3D2cJ1HKptQNUBRwjMvduG5by+ONxtuNJ7XGtQfFOyLJl4QFCWCSNwVEzv0CqAfrbq3XmqsAMXZJeMNo0OG/XpgQT2W4oP0QcyW9hHvxe6S34DjXDCaN8SreTJqq/8n3gQIj2/bkW9gGOHceZ98BDVXAeVXQj4opd3qF1V3DkP7NhUZEpgqHZglpkmcZqiufpdJbhnbjjIAUPN9c2dpEKWiR+UTR0hUedERDEGge6caM0XpfKPDiFXQpNgMBhatRkp9iNwoCIbp1muzYZpiu8YFNFbZmRmXcW8o8b3/MoEWZZTvMcffk7Yk+K0lItLmR7wjAJVZXM/7CbP6bVECbYAGNaQ50ZlPgt1wAU9VoE9oV3U2bVmV6Vdic1w1LS3pCOT9DNOXkGvbxLxp/gwJVFwkHVBAHnSLCyRyNn3GL+rzPO0Mzej2Q9stPUExcoMBkm6e4pUatynHONw== herwig@lenotox"
    ];
  };
  security.sudo.wheelNeedsPassword = true;

  hardware = {
    pulseaudio.enable = true;
    # nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    nvidia.modesetting.enable = false;
    nvidia.powerManagement.enable = true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
      ];
    };
    enableRedistributableFirmware = true;
  };

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      challengeResponseAuthentication = false;
      startWhenNeeded = true;
      forwardX11 = true;
    };
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" "nouveau" "nv" "vesa" ];
      deviceSection = ''
        Option "Coolbits" "12"
      '';
      displayManager.gdm.enable = true;
      displayManager.gdm.autoSuspend = false;
      displayManager.gdm.wayland = false;
      displayManager.gdm.nvidiaWayland = false;
      displayManager.lightdm.enable = false;
      desktopManager.gnome.enable = true;
      desktopManager.plasma5.enable = true;
      layout = "de";
      xkbOptions = "eurosign:e";
    };
    avahi = {
      # FIXME enable discovery
      enable = true;
      nssmdns = true;
      wideArea = false;
    };
    printing.enable = true;
    locate.enable = false;
    fstrim.enable = true;
    flatpak.enable = true;
  };

  programs = {
    ## get this via flatpak
    # steam.enable = true;
    mosh.enable = true;
    ssh.askPassword = lib.mkForce "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    btop htop iotop iftop lshw powertop
    pmutils hdparm traceroute which
    file tree tmux lsof rlwrap pass
    vim emacs ed nano git gnumake
    wget curl ent socat rsync nmap tunctl
    firefox thunderbird chromium libreoffice gimp inkscape
    virt-manager qemu libguestfs p7zip
    python3 pciutils xorg.xkill spotify
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
    # qemu.ovmf.enable = true;
    # qemu.ovmf.package = pkgs.OVMFFull;
  };

  # environment.etc."polkit-1/localauthority.conf.d/90-silence-steam.pkla".text = ''
  #   [Stop steam user from prompting for network permissions]
  #   Identity=unix-user:herwig;unix-user:nara
  #   Action=org.freedesktop.NetworkManager.settings.modify.system
  #   ResultActive=no
  #   ResultInactive=no
  #   ResultAny=no
  # '';

  ## FIXME: port to NM
  # networking.nat.externalInterface = "wlan0";
  # networking.nat.internalInterfaces = [ "enp0s31f6" ];
  # networking.firewall.allowedUDPPorts = [ 67 ]; # for dhcp
  # systemd.network.networks."10-enp9s0" = {
  #   matchConfig.Name = "enp9s0";
  #   address = [ "10.0.0.1/24" ];
  #   networkConfig = {
  #     ## handled by firewall config
  #     # IPMasquerade = "yes";
  #     DHCPServer = "yes";
  #   };
  #   dhcpServerConfig = {
  #     PoolOffset= 32;
  #     PoolSize= 32;
  #   };
  # };

  nixpkgs.config = {
    allowUnfree = true;
    ## wayland flags
    # chromium.commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
  };

  nix = {
    buildCores = 12;
    extraOptions = ''
      binary-caches-parallel-connections = 24
      gc-keep-outputs = true
      gc-keep-derivations = true
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

