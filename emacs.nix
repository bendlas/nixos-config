{ emacs, emacsPackagesNgGen, pkgs }:

let emacsPackages = emacsPackagesNgGen (emacs.override {
  inherit (pkgs) alsaLib imagemagick acl gpm;
  inherit (pkgs.gnome3) gconf;
  withGTK3 = true; withGTK2 = false;
}); in

emacsPackages.emacsWithPackages ( epkgs: with (
       epkgs.melpaPackages
    // epkgs.elpaPackages
    // epkgs.melpaStablePackages
  ); [

  cider clj-refactor cljsbuild-mode clojars clojure-mode
  cyberpunk-theme gh gitignore-mode groovy-mode haskell-mode htmlize
  ibuffer-tramp ido-ubiquitous ido-completing-read-plus idris-mode
  igrep javap-mode ninja-mode igrep geiser commenter js2-mode
  js2-highlight-vars js2-refactor js2-closure json-mode json-reformat
  jvm-mode multiple-cursors nix-mode nixos-options org org-present
  paredit nim-mode mmm-mode markdown-mode magit-gh-pulls macrostep
  levenshtein php-mode rainbow-delimiters skewer-mode skewer-less
  skewer-reload-stylesheets slamhound slime smex undo-tree wanderlust
  yasnippet magit with-editor string-edit
  

  pkgs.ghostscript pkgs.aspell
])
