{ emacsUnstable, emacsPackagesFor
, enableDebugInfo, fetchFromGitHub
, pkgs
}:

let

  baseEmacs = emacsUnstable;

  # baseEmacs = emacsGit.overrideAttrs (_: {
  #   src = pkgs.fetchFromGitHub {
  #     owner = "commercial-emacs";
  #     repo = "commercial-emacs";
  #     rev = "54a6e8174e22c649c3c3896f15b2a2e05c13c5cc";
  #     sha256 = "sha256-fureWFTpizuzQ7YfsCJ5fh+YfVDR3goTMd0zKsd0bhk=";
  #   };
  # });

  emacsWithPackagesFor = emacsPackages: pfn:
    emacsPackages.emacsWithPackages
      (compOverrides [
        (epkgs: epkgs // epkgs.melpaPackages)
        # see https://github.com/NixOS/nix-mode/pull/177
        (updatePackage "nix-mode" (epkgs: old: {
          propagatedBuildInputs = old.propagatedBuildInputs ++ [ epkgs.reformatter ];
          propagatedUserEnvPkgs = old.propagatedUserEnvPkgs ++ [ epkgs.reformatter ];
        }))
        # (patchPackage "volume" "https://patch-diff.githubusercontent.com/raw/dbrock/volume.el/pull/8.patch" "sha256-6e5UXtWSeP3iJFhsLw6KrIZGYmjMkip2oiF+yn40VaE=")
        # (patchPackage "benchmark-init" "https://patch-diff.githubusercontent.com/raw/dholm/benchmark-init-el/pull/16.patch" "sha256-lVEKRgy60uvpl3jAeuo2mabldU8SwukHfwTgoAi9A9Q=")
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
    (epkgs.trivialBuild {
      pname = "emacs-gdb";
      version = "bendlas";
      src = pkgs.fetchFromGitHub {
        owner = "weirdNox";
        repo = "emacs-gdb";
        rev = "985423594e91a4fb774d4dc5322d4b9750393419";
        sha256 = "sha256-CDwbFTQ/CCGasEG5n3ww/moe7HgO6CFR+hpWY5L79Sw=";
      };
      packageRequires = with epkgs; [ hydra ];
      preBuild = ''
        echo BUILD
        make gdb-module.so
      '';
      postInstall = ''
        echo "echo \$installPhase"
        echo "$installPhase"
        echo "typeset -f installPhase"
        typeset -f installPhase
        echo "ls -l"
        ls -l
        install *.so $LISPDIR
      '';
    })

    cyberpunk-theme gh groovy-mode haskell-mode htmlize
    ibuffer-tramp epkgs."ido-completing-read+" idris-mode crm-custom
    javap-mode ninja-mode commenter js2-mode xref-js2 # geiser
    js2-highlight-vars js2-refactor js2-closure json-mode json-reformat
    typescript-mode
    jvm-mode multiple-cursors nixos-options org org-present
    paredit nim-mode mmm-mode markdown-mode macrostep
    levenshtein php-mode rainbow-delimiters skewer-mode skewer-less
    skewer-reload-stylesheets smex undo-tree wanderlust # elixir-mode
    alchemist # erlang-mode
    yasnippet with-editor string-edit-at-point keyfreq scala-mode
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
    parseclj # spiral
    magit-gh-pulls
    flycheck toml-mode rust-mode cargo flycheck-rust
    graphviz-dot-mode

    ## LSP support
    lsp-mode ccls
  ];

  nativePkgs = with pkgs; [
    ghostscript aspell
    ## LSP packages
    clojure-lsp ccls
    rnix-lsp nil
    rust-analyzer
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

  updatePackage = pname: f: epkgs: epkgs // {
    "${pname}" = epkgs."${pname}".overrideAttrs (f epkgs);
  };

  sourcePackage = pname: src: epkgs: epkgs // {
    "${pname}" = epkgs."${pname}".overrideAttrs (old: {
      inherit src;
    });
  };

  ## emacs with X
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
  emacsWithPackages = emacsWithPackagesFor emacsPackages;
  emacs = emacsWithPackages (epkgs: []);

  ## emacs without X
  emacsUnwrappedNox = baseEmacs.override {
    withX = false;
    withNS = false;
    withGTK2 = false;
    withGTK3 = false;
  };
  emacsPackagesNox = emacsPackagesFor (
    enableDebugInfo (
      emacsUnwrappedNox
    )
  );
  emacsWithPackagesNox = emacsWithPackagesFor emacsPackagesNox;
  emacsNox = emacsWithPackagesNox (epkgs: []);

in {

  inherit emacsPackages emacsWithPackages emacs;
  inherit emacsPackagesNox emacsWithPackagesNox emacsNox;

}
