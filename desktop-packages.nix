{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ## Chats

    tdesktop signal-desktop

    ## Games

    wine winetricks

    # sauerbraten
    dwarf-fortress dwarf-therapist

    ## Dev tools

    # nixops ## not working
    visualvm rustc cargo nim ant go dosbox

    nodejs debootstrap mercurial subversion cmake guile valgrind sbcl
    dos2unix nodePackages.grunt-cli mono luajit luarocks racket

    # dust

    radare2 # radare2-cutter ## not building
    nix-generate-from-cpan

    python3 python3Packages.pip pypy

    boot leiningen gettext jdk maven3 clojure

    pkgsi686Linux.stalin

    diffoscope

    graphviz

    ## Video

    inkscape blender antimony gimp openscad gnome.cheese vlc

    ## Audio

    # clementine

    gnome.gnome-sound-recorder audacity qjackctl

    ## Documents

    abiword gnumeric lyx

    ## Networking

    firefox deluge ungoogled-chromium-bendlas chromium youtube-dl
    thunderbird bitcoin ipfs

    # ml-workbench
    webtorrent_desktop

  ];

}
