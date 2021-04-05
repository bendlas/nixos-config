{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ## Chats

    tdesktop teamspeak_client signal-desktop skype

    ## Games

    wine winetricks
    steam

    # sauerbraten
    dwarf-fortress dwarf-therapist

    ## Dev tools

    # nixops ## not working
    idea.idea-community visualvm rustc cargo nim ant go dosbox

    nodejs debootstrap mercurial subversion cmake guile valgrind sbcl
    dos2unix nodePackages.grunt-cli mono luajit luarocks racket

    # dust

    radare2 radare2-cutter nix-generate-from-cpan

    python3 python3Packages.pip pypy

    boot leiningen gettext jdk maven3 clojure lumo

    pkgsi686Linux.stalin

    diffoscope

    graphviz nix-du

    ## Video

    inkscape blender antimony gimp openscad gnome3.cheese vlc

    ## Audio

    # clementine

    gnome3.gnome-sound-recorder audacity qjackctl

    ## Documents

    abiword gnumeric lyx

    ## Networking

    firefox deluge ungoogled-chromium-bendlas chromium youtube-dl
    thunderbird bitcoin ipfs

    # ml-workbench
    webtorrent_desktop

  ];

}
