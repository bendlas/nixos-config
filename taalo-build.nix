{ stdenv, lib, runCommand, nix }:

let
  nixRemote = "ssh-ng://nix-remote-build@taalo.headcounter.org?compress=true";

  mkScript = cmd: lib.escapeShellArg ''
    #!${stdenv.shell}
    export NIX_REMOTE=${lib.escapeShellArg nixRemote}
    exec ${lib.escapeShellArg nix}/bin/${cmd} "$@"
  '';

  downloadScript = lib.escapeShellArg ''
    #!${stdenv.shell}
    exec ${lib.escapeShellArg nix}/bin/nix-build --option binary-caches "https://cache.nixos.org/ https://headcounter.org/hydra" "$@"
  '';

  bdScript = lib.escapeShellArg ''
    #!${stdenv.shell}
    taalo-build "$@"
    exec taalo-download "$@"
  '';

in runCommand "taalo-build" {} ''
  mkdir -p "$out/bin"

  echo -n ${mkScript "nix-build"} > "$out/bin/taalo-build"
  echo -n ${mkScript "nix-store -r"} > "$out/bin/taalo-realize"

  echo -n ${downloadScript} > "$out/bin/taalo-download"
  echo -n ${bdScript} > "$out/bin/taalo-bd"

  chmod +x "$out"/bin/taalo-{build,realize,download,bd}
''
