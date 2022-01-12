{ emacsPackages }:

emacsPackages.trivialBuild {
  pname = "bendlas";
  version = "bendlas";
  src = ./emacs.d;
  packageRequires = [ emacsPackages.exwm ];
  preBuild = ''
    make loaddefs
    cd lisp
  '';
}
