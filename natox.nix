{ config, lib, pkgs, ... }:

{
  bendlas.machine = "natox";
  imports = [
    # shared with ./base.nix
    ./log.nix ./sources.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix
    # new base
    ./access.module.nix ./tmpfs.module.nix
    # -
    ./epson-stylus-photo-r3000.module.nix
    ./samba.module.nix
    ./ark.module.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.kernelParams = [ "amd_iommu=on" ];

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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
  console.keyMap = "us";

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
    };
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
    openssh.forwardX11 = true;
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" "nouveau" "nv" "vesa" ];
      deviceSection = ''
        Option "Coolbits" "12"
      '';
      displayManager.gdm.enable = true;
      displayManager.gdm.autoSuspend = false;
      displayManager.gdm.wayland = false;
      displayManager.lightdm.enable = false;
      desktopManager.gnome.enable = true;
      desktopManager.plasma5.enable = false;
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
    # FIXME package proprietary epson-stylus-photo ...
    printing.drivers = [ pkgs.epson-escpr pkgs.epson-escpr2 ];
    locate.enable = false;
    fstrim.enable = true;
    flatpak.enable = true;
  };

  programs = {
    ## get this via flatpak
    # steam.enable = true;
    ## only needed this for plasma5 combiened with gnome
    # ssh.askPassword = lib.mkForce "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
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
    teamspeak_client
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
    settings.max-jobs = 6;
    settings.cores = 12;
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

  ## Hardware Configuration
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7d91e41d-5551-4588-bd71-6bc731beee53";
    fsType = "xfs";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/6A08-8778";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/6215e0be-9063-4c9e-b049-ce655128356c"; }
  ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.sane.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
