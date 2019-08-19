{ emacs26, emacsPackagesGen, enableDebugInfo, pkgs }:

let

  builtinPackages = epkgs: (with epkgs; [

    cyberpunk-theme gh gitignore-mode groovy-mode haskell-mode htmlize
    ibuffer-tramp ido-completing-read-plus idris-mode crm-custom
    javap-mode ninja-mode geiser commenter js2-mode xref-js2
    js2-highlight-vars js2-refactor js2-closure json-mode json-reformat
    jvm-mode multiple-cursors nixos-options org org-present
    paredit nim-mode mmm-mode markdown-mode macrostep
    levenshtein php-mode rainbow-delimiters skewer-mode skewer-less
    skewer-reload-stylesheets smex undo-tree wanderlust erlang elixir-mode alchemist
    yasnippet with-editor string-edit keyfreq scala-mode
    uuidgen systemtap-mode gn coffee-mode cask-mode elf-mode lua-mode
    elfeed elfeed-goodies elfeed-web elfeed-org volume dockerfile-mode yaml-mode
    impatient-mode cmake-mode livescript-mode
    ivy ivy-xref treemacs elmacro

  ]) ++ (with epkgs.melpaPackages; [

    magit magit-popup cljsbuild-mode clojars nix-mode
    clj-refactor clojure-mode
    slime cider ensime
    tern company company-tern
    spiral parseclj
    # magit-gh-pulls ## tries to access /homeless-shelter
    flycheck lsp-mode toml-mode rust-mode cargo flycheck-rust
  ]) ++ (with pkgs; [

    ghostscript aspell

  ]);

  emacsPackages = emacsPackagesGen (
    enableDebugInfo (emacs26.override {
      inherit (pkgs) alsaLib imagemagick acl gpm Xaw3d;
      withGTK3 = true; withGTK2 = false;
      withXwidgets = true;
    }));

  emacsWithPackages = pfn:
    emacsPackages.emacsWithPackages (epkgs:
      (builtinPackages epkgs) ++ (pfn epkgs));

  emacs = emacsWithPackages (_: []);


in {

  inherit emacsPackages emacs emacsWithPackages;

}
