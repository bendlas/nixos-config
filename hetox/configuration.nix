# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./gitlab.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.loader.grub.devices = [ "/dev/sda" ];

  networking.hostName = "hetox"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ed vim emacs-nox tree git
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?


  # Initial empty root password for easy login:
  users.users.root.initialHashedPassword = "";
  services.openssh.permitRootLogin = "prohibit-password";

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC70QgW3EnX781iFOlojPnwST1CiMZaWdQEJNgSbsvaEFeHwFNDr9Ma2kTzjFQnpLKfb7eAr7BsUX3uSJjFq6MDTfgynCSXtgOxaahTfoVFFvJdGZPtXU09k7xSW043A7Ziwi8iPM0EFKUb85W6v4S1VACpjD57SEs4enUsyrXO8XVBDpqRQLdPDXjyNqzZ0zafbs22bDYDUmgr3UTItSzrGG7fzPyP3D2cJ1HKptQNUBRwjMvduG5by+ONxtuNJ7XGtQfFOyLJl4QFCWCSNwVEzv0CqAfrbq3XmqsAMXZJeMNo0OG/XpgQT2W4oP0QcyW9hHvxe6S34DjXDCaN8SreTJqq/8n3gQIj2/bkW9gGOHceZ98BDVXAeVXQj4opd3qF1V3DkP7NhUZEpgqHZglpkmcZqiufpdJbhnbjjIAUPN9c2dpEKWiR+UTR0hUedERDEGge6caM0XpfKPDiFXQpNgMBhatRkp9iNwoCIbp1muzYZpiu8YFNFbZmRmXcW8o8b3/MoEWZZTvMcffk7Yk+K0lItLmR7wjAJVZXM/7CbP6bVECbYAGNaQ50ZlPgt1wAU9VoE9oV3U2bVmV6Vdic1w1LS3pCOT9DNOXkGvbxLxp/gwJVFwkHVBAHnSLCyRyNn3GL+rzPO0Mzej2Q9stPUExcoMBkm6e4pUatynHONw== herwig@lenix"
  ];
}
