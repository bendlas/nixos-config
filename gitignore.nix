pkgs:
let
  src = pkgs.fetchFromGitHub {
    owner = "hercules-ci";
    repo = "gitignore.nix";
    # put the latest commit sha of gitignore Nix library here:
    rev = "a20de23b925fd8264fd7fad6454652e142fd7f73";
    # use what nix suggests in the mismatch message here:
    sha256 = "sha256-8DFJjXG8zqoONA1vXtgeKXy68KdJL5UaXR8NtVMUbx8=";
  };
  srcInst = import src {
    inherit (pkgs) lib;
  };
in srcInst // { inherit src; }
# .gitignoreSource
# // {
#   inherit src;
# }
