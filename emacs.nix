{ emacs27, emacsPackagesGen, enableDebugInfo, pkgs }:

let

  builtinPackages = epkgs: (with epkgs; with melpaPackages; [

    cyberpunk-theme gh gitignore-mode groovy-mode haskell-mode htmlize
    ibuffer-tramp epkgs."ido-completing-read+" idris-mode crm-custom
    javap-mode ninja-mode commenter js2-mode xref-js2 # geiser
    js2-highlight-vars js2-refactor js2-closure json-mode json-reformat
    jvm-mode multiple-cursors nixos-options org org-present
    paredit nim-mode mmm-mode markdown-mode macrostep
    levenshtein php-mode rainbow-delimiters skewer-mode skewer-less
    skewer-reload-stylesheets smex undo-tree wanderlust elixir-mode alchemist # erlang-mode
    yasnippet with-editor string-edit keyfreq scala-mode
    uuidgen systemtap-mode gn-mode coffee-mode cask-mode elf-mode lua-mode
    elfeed elfeed-goodies elfeed-web elfeed-org volume dockerfile-mode yaml-mode
    impatient-mode cmake-mode livescript-mode
    ivy ivy-xref treemacs elmacro hy-mode robe haml-mode

    edit-list refine
    golden-ratio workgroups2

    # projectile projectile-direnv projectile-codesearch
    # persp-mode persp-mode-projectile-bridge
    exwm-x

  #]) ++ (with epkgs.melpaPackages; [

    magit magit-popup cljsbuild-mode clojars nix-mode
    clj-refactor clojure-mode
    slime cider # ensime
    tern forth-mode
    spiral parseclj
    # magit-gh-pulls ## tries to access /homeless-shelter
    flycheck lsp-mode toml-mode rust-mode cargo flycheck-rust
    graphviz-dot-mode
  ]) ++ (with pkgs; [

    ghostscript aspell

  ]);

  emacsPackages = emacsPackagesGen (
    enableDebugInfo (emacs27.override {
      inherit (pkgs) alsa-lib imagemagick acl gpm Xaw3d;
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
