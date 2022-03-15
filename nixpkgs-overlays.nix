[
  (
    let
      ## (import <emacs-overlay>)
      ## taking this from self: super: here,
      ## produces an infinite recursion
      self = import <nixpkgs> {};
    in
      import (self.fetchgit {
        inherit (self.lib.importJSON ./emacs-overlay.json) url rev sha256 fetchSubmodules;
      })
  )
]
