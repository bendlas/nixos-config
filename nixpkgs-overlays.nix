[
  (let pkgs = import <nixpkgs> {}; in
   import (pkgs.fetchgit {
    inherit (pkgs.lib.importJSON ./emacs-overlay.json) url rev sha256 fetchSubmodules;
  }))
]
