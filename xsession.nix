{ config, lib, pkgs, ... }:

let
  gnome3 = config.environment.gnome3.packageSet;
  # Prioritize nautilus by default when opening directories
  mimeAppsList = pkgs.writeTextFile {
    name = "gnome-mimeapps";
    destination = "/share/applications/mimeapps.list";
    text = ''
      [Default Applications]
      inode/directory=nautilus.desktop;org.gnome.Nautilus.desktop
    '';
  };

  nixos-gsettings-desktop-schemas = pkgs.stdenv.mkDerivation {
    name = "nixos-gsettings-desktop-schemas";
    gnomeDark = pkgs.nixos-artwork.wallpapers.gnome-dark;
    buildCommand = ''
     mkdir -p $out/share/nixos-gsettings-schemas/nixos-gsettings-desktop-schemas
     cp -rf ${gnome3.gsettings_desktop_schemas}/share/gsettings-schemas/gsettings-desktop-schemas*/glib-2.0 $out/share/nixos-gsettings-schemas/nixos-gsettings-desktop-schemas/
     chmod -R a+w $out/share/nixos-gsettings-schemas/nixos-gsettings-desktop-schemas
     cat - > $out/share/nixos-gsettings-schemas/nixos-gsettings-desktop-schemas/glib-2.0/schemas/nixos-defaults.gschema.override <<- EOF
       [org.gnome.desktop.background]
       picture-uri='$gnomeDark/share/artwork/gnome/Gnome_Dark.png'

       [org.gnome.desktop.screensaver]
       picture-uri='$gnomeDark/share/artwork/gnome/Gnome_Dark.png'
     EOF
     ${pkgs.glib.dev}/bin/glib-compile-schemas $out/share/nixos-gsettings-schemas/nixos-gsettings-desktop-schemas/glib-2.0/schemas/
    '';
  };
  addSessionPath = [ gnome3.gnome_shell gnome3.gnome-shell-extensions ];
in {
  security.polkit.enable = true;
  services = {
    upower.enable = true;
    telepathy.enable = true;
    udisks2.enable = true;
    accounts-daemon.enable = true;
    geoclue2.enable = true;
    gnome3 = {
      at-spi2-core.enable = true;
      evolution-data-server.enable = true;
      gnome-documents.enable = true;
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
      gnome-user-share.enable = true;
      gvfs.enable = true;                      
      seahorse.enable = true;        
      sushi.enable = true;           
      tracker.enable = true;         
    };
    xserver.desktopManager.session = lib.singleton {
      name = "Erdgeist";
      start = ''
          # Set GTK_DATA_PREFIX so that GTK+ can find the themes
          export GTK_DATA_PREFIX=${config.system.path}

          # find theme engines
          export GTK_PATH=${config.system.path}/lib/gtk-3.0:${config.system.path}/lib/gtk-2.0

          export XDG_MENU_PREFIX=gnome

          ${lib.concatMapStrings (p: ''
            if [ -d "${p}/share/gsettings-schemas/${p.name}" ]; then
              export XDG_DATA_DIRS=$XDG_DATA_DIRS''${XDG_DATA_DIRS:+:}${p}/share/gsettings-schemas/${p.name}
            fi

            if [ -d "${p}/lib/girepository-1.0" ]; then
              export GI_TYPELIB_PATH=$GI_TYPELIB_PATH''${GI_TYPELIB_PATH:+:}${p}/lib/girepository-1.0
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH''${LD_LIBRARY_PATH:+:}${p}/lib
            fi
          '') addSessionPath}

          # Override default mimeapps
          export XDG_DATA_DIRS=$XDG_DATA_DIRS''${XDG_DATA_DIRS:+:}${mimeAppsList}/share

          # Override gsettings-desktop-schema
          export XDG_DATA_DIRS=${nixos-gsettings-desktop-schemas}/share/nixos-gsettings-schemas/nixos-gsettings-desktop-schemas''${XDG_DATA_DIRS:+:}$XDG_DATA_DIRS

          # Let nautilus find extensions
          export NAUTILUS_EXTENSION_DIR=${config.system.path}/lib/nautilus/extensions-3.0/

          # Find the mouse
          export XCURSOR_PATH=~/.icons:${config.system.path}/share/icons

          # Update user dirs as described in http://freedesktop.org/wiki/Software/xdg-user-dirs/
          ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update

          # Find the mouse
          export XCURSOR_PATH=~/.icons:${config.system.path}/share/icons

          ${pkgs.stumpwm-git}/bin/stumpwm&
          waitPID=$!
          #${gnome3.gnome_session}/bin/gnome-session&
          #waitPID=$!
      '';
    };
  };
  environment = {
    variables = {
      GIO_EXTRA_MODULES = [
        "${gnome3.dconf}/lib/gio/modules"
        "${gnome3.glib_networking}/lib/gio/modules"
        "${gnome3.gvfs}/lib/gio/modules"
      ];
      # mouse wheel in gnome apps
      GDK_CORE_DEVICE_EVENTS = "1";
    };
    systemPackages = gnome3.corePackages ++ gnome3.optionalPackages;
    pathsToLink = [ "/share" ];
  };
  hardware = {
    pulseaudio.enable = true;
    bluetooth.enable = true;
  };
}
