let
  # pkgsFun = import ../nixpkgs/default.nix;
  pkgsFun = import <nixpkgs/default.nix>;
  pkgsNoParams = pkgsFun {};
  crossSystem = {
    system = "aarch64-linux";
    config = "aarch64-unknown-linux-gnueabi";
    bigEndian = false;
    arch = "aarch64";
    #float = "hard";
    #fpu = "vfp";
    withTLS = true;
    libc = "glibc";
    platform = pkgsNoParams.platforms.aarch64-multiplatform;
    # openssl.system = "linux-generic32";
    gcc = {
      arch = "armv8-a";
      # fpu = "vfp";
      # float = "softfp";
      # abi = "aapcs-linux";
    };
  };
# in import ./nixos {
#   system = "aarch64-linux";
#   configuration = {
#     imports = [
#       ./rpi3.nix
#       # ./nixos/modules/installer/cd-dvd/sd-image-aarch64.nix
#     ];
#     nixpkgs.config = {
#       packageOverrides = pkgs: (pkgsFun { inherit crossSystem; });
#     };
#   };
# }
in (pkgsFun { inherit crossSystem; })
