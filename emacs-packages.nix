{ emacsGcc, emacsPackagesFor
, enableDebugInfo, fetchFromGitHub
, pkgs
}:

let

  baseEmacs = emacsGcc;

  emacsWithPackages = pfn:
    emacsPackages.emacsWithPackages
      (compOverrides [
        (epkgs: epkgs // epkgs.melpaPackages)
        (patchPackage "volume" "https://patch-diff.githubusercontent.com/raw/dbrock/volume.el/pull/8.patch" "sha256-6e5UXtWSeP3iJFhsLw6KrIZGYmjMkip2oiF+yn40VaE=")
        (patchPackage "benchmark-init" "https://patch-diff.githubusercontent.com/raw/dholm/benchmark-init-el/pull/16.patch" "sha256-lVEKRgy60uvpl3jAeuo2mabldU8SwukHfwTgoAi9A9Q=")
        # (sourcePackage "cider" (fetchFromGitHub {
        #   owner = "clojure-emacs";
        #   repo = "cider";
        #   rev = "v1.2.0";
        #   sha256 = "sha256-Lovqe0CYnNH/65mHpBRxQBXsGZSYn2yLYf8s43KDQbA=";
        # }))
        (epkgs: builtinPackages epkgs ++ pfn epkgs ++ nativePkgs)
      ]);

  builtinPackages = epkgs: with epkgs; [
    (pkgs.callPackage ./emacs-bendlas.nix { emacsPackages = epkgs; })

    cyberpunk-theme gh groovy-mode haskell-mode htmlize
    ibuffer-tramp epkgs."ido-completing-read+" idris-mode crm-custom
    javap-mode ninja-mode commenter js2-mode xref-js2 geiser
    js2-highlight-vars js2-refactor js2-closure json-mode json-reformat
    jvm-mode multiple-cursors nixos-options org org-present
    paredit nim-mode mmm-mode markdown-mode macrostep
    levenshtein php-mode rainbow-delimiters skewer-mode skewer-less
    skewer-reload-stylesheets smex undo-tree wanderlust elixir-mode alchemist # erlang-mode
    yasnippet with-editor string-edit keyfreq scala-mode
    uuidgen systemtap-mode gn-mode coffee-mode cask-mode elf-mode lua-mode
    elfeed elfeed-goodies elfeed-web elfeed-org volume dockerfile-mode yaml-mode
    impatient-mode livescript-mode cmake-mode adoc-mode
    ivy ivy-xref treemacs elmacro hy-mode robe haml-mode

    edit-list refine
    golden-ratio workgroups2

    benchmark-init

    # projectile projectile-direnv projectile-codesearch
    # persp-mode persp-mode-projectile-bridge
    exwm-x

    magit magit-popup cljsbuild-mode clojars nix-mode
    clj-refactor clojure-mode
    slime cider # ensime
    tern forth-mode
    spiral parseclj
    magit-gh-pulls
    flycheck lsp-mode toml-mode rust-mode cargo flycheck-rust
    graphviz-dot-mode
  ];

  nativePkgs = with pkgs; [
    ghostscript aspell
  ];

  compOverrides = overrides: epkgs:
    if 0 == builtins.length overrides
    then epkgs
    else compOverrides (builtins.tail overrides) ((builtins.head overrides) epkgs);
  
  patchPackage = pname: url: sha256: epkgs: epkgs // {
    "${pname}" = epkgs."${pname}".overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        (pkgs.fetchpatch {
          inherit url sha256;
        })
      ];
    });
  };

  sourcePackage = pname: src: epkgs: epkgs // {
    "${pname}" = epkgs."${pname}".overrideAttrs (old: {
      inherit src;
    });
  };

  emacsUnwrapped = baseEmacs.override {
    inherit (pkgs) alsa-lib imagemagick acl gpm Xaw3d;
    withGTK3 = true; withGTK2 = false;
    withXwidgets = true;
  };

  emacsPackages = emacsPackagesFor (
    enableDebugInfo (
      emacsUnwrapped
    )
  );

  # emacs = emacsWithPackages builtinPackages;
  emacs = emacsWithPackages (epkgs: []);


in {

  inherit emacsPackages emacsWithPackages emacs;

}
