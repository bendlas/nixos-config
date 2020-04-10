{ pkgFile
, source ? <nixpkgs>
, lib
, stdenv
, writeScriptBin
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
in (writeScriptBin "update-nix-env" ''
  #!${stdenv.shell} -e
  exec ${nix}/bin/nix-env -f ${source} --keep-going -riA ${concatStringsSep " " packages}
'') // {
  inherit packages;
}
