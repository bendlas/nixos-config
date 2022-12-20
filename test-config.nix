{ config, pkgs, lib, ... }:
{
  imports = [
    # ./desktop.nix ./dev.nix
    ./base.nix
    ./valheim-server.module.nix
  ];
  bendlas.machine = "test-config";
  fileSystems."/" = { device = "/dev/null"; };
  boot.loader.grub.enable = false;
  # boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "cafebabe";
  networking.nat.externalInterface = "dummy";
  # services.xserver.videoDrivers = [ "nvidia" "nouveau" "nv" "vesa" "intel" ];
  services.avahi.enable = lib.mkForce false;
  services.valheim-server.password = "";
  system.extraDependencies = with pkgs; [
    # # virtualboxExtpack
    # bluez5 crda wireless-regdb
    # vaapiVdpau
    # splix brgenml1cupswrapper
    # firmwareLinuxNonfree
    # # opencl-icd mkl
  ];

}
