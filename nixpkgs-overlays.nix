[
  (
    let dsc = builtins.fromJSON (builtins.readFile ./emacs-overlay.json); in
    import (builtins.fetchGit {
      inherit (dsc) url rev;
      ref = dsc.branch;
    })
  )
]
