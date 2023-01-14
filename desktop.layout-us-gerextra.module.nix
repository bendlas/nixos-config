{ pkgs, lib, ...}:

{
  services.xserver = {
    layout = lib.mkDefault "us-gerextra";
    extraLayouts.us-gerextra = {
      description = ''
        English layout with german umlauts on AltGr
      '';
      languages = [ "eng" "ger" ];
      keycodesFile = pkgs.writeText "us-gerextra-keycodes" ''
        xkb_keycodes "us-gerextra" { include "evdev+aliases(qwerty)" };
      '';
      geometryFile = pkgs.writeText "us-gerextra-geometry" ''
        xkb_geometry "us-gerextra" { include "pc(pc104)" };
      '';
      typesFile = pkgs.writeText "us-gerextra-types" ''
        xkb_types "us-gerextra" { include "complete" };
      '';
      symbolsFile = pkgs.writeText "us-gerextra-symbols" ''
        xkb_symbols "us-gerextra" {
          key <AD03> { [ e, E, EuroSign ] };
          key <AD07> { [ u, U, udiaeresis, Udiaeresis ] };
          key <AD09> { [ o, O, odiaeresis, Odiaeresis ] };
          key <AC01> { [ a, A, adiaeresis, Adiaeresis ] };
          key <AC02> { [ s, S, ssharp, U1E9E ] };
          augment "pc+us+inet(evdev)+ctrl(nocaps)+level3(ralt_switch)"
        };
      '';
    };
  };
}
