{ config, lib, pkgs, ... }:

{

  nixpkgs.overlays = [
    (self: super: {
      epson-inkjet-printer-stylus-photo-r3000 = self.callPackage ./epson-inkjet-printer-stylus-photo-r3000.package.nix {
        # enableDebug = true;
      };
    })
  ];

  services.printing.enable = true;
  # services.printing.logLevel = "debug";
  services.printing.drivers = [ pkgs.epson-inkjet-printer-stylus-photo-r3000 ];

}
