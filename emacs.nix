{ emacs25, emacsPackagesNgGen, enableDebugInfo, pkgs }:

let

  builtinPackages = epkgs: (with epkgs; [

    cyberpunk-theme gh gitignore-mode groovy-mode haskell-mode htmlize
    ibuffer-tramp ido-completing-read-plus idris-mode crm-custom
    javap-mode ninja-mode geiser commenter js2-mode
    js2-highlight-vars js2-refactor js2-closure json-mode json-reformat
    jvm-mode multiple-cursors nix-mode nixos-options org org-present
    paredit nim-mode mmm-mode markdown-mode magit-gh-pulls macrostep
    levenshtein php-mode rainbow-delimiters skewer-mode skewer-less
    skewer-reload-stylesheets smex undo-tree wanderlust erlang elixir-mode alchemist
    yasnippet magit magithub with-editor string-edit keyfreq scala-mode # ensime
    uuidgen systemtap-mode gn coffee-mode cask-mode elf-mode
    elfeed elfeed-goodies elfeed-web elfeed-org volume dockerfile-mode yaml-mode
    impatient-mode # cmake-mode

    pkgs.ghostscript pkgs.aspell

    # tramp # use more recent version
    # slamhound # not available any more

  ]) ++ (with epkgs.melpaPackages; [

    # use more recent (unstable) versions

    clj-refactor slime
    cljsbuild-mode clojars clojure-mode cider
  
  ]);

  emacsPackages = emacsPackagesNgGen (
    enableDebugInfo (emacs25.override {
      inherit (pkgs) alsaLib imagemagick acl gpm;
      inherit (pkgs.gnome3) gconf;
      withGTK3 = true; withGTK2 = false;
    }));

  emacsWithPackages = pfn:
    emacsPackages.emacsWithPackages (epkgs:
      (builtinPackages epkgs) ++ (pfn epkgs));

  emacs = emacsWithPackages (_: []);


in {

  inherit emacsPackages emacs emacsWithPackages;

}
