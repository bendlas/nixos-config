{ pkgs, ... }:

{
  console.useXkbConfig = true;
  environment.systemPackages = with pkgs; [
    ## Admin

    st gparted dfeet dbus

    libva-utils

    xorg.xhost xorg.xdpyinfo

    ## Chats

    mumble_git

    ## Dev tools

    xorg.xkill xorg.xbacklight xorg.xrandr xorg.xev

    xdotool

    ## Video

    gnome.cheese vlc gcolor3 glxinfo youtube-dl

    ## Audio

    gnome.gnome-sound-recorder

    ## Notification

    libnotify

  ];
}
