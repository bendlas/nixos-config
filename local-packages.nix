{ pkgFile
, source ? <nixpkgs>
, lib
, stdenv
, writeScriptBin
, symlinkJoin
, nix
}:
with lib;
with builtins;
let
  ssplit = sepRegex: str:
    filter isString (split sepRegex str);
  parsePackages = ps:
    ## remove comment lines and split into words
    filter (word: isNull (match " *" word))
      (concatMap (line: ssplit " " (elemAt (match "([^#]*)( *#.*)?" line) 0))
        (ssplit "\n" ps));
  packages = parsePackages (readFile pkgFile);
  updateScript = writeScriptBin "update-nix-env" ''
    #!${stdenv.shell} -e
    exec ${nix}/bin/nix-env -f ${source} --keep-going -riA ${concatStringsSep " " packages}
  '';
  buildScript = writeScriptBin "build-nix-env" ''
    #!${stdenv.shell} -e
    exec ${nix}/bin/nix-build --no-out-link ${source} --keep-going -A ${concatStringsSep " -A " packages}
  '';
in ( symlinkJoin { name = "local-packages"; paths = [ buildScript updateScript ]; } ) // {
  inherit packages;
}
