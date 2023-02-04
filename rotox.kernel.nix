{ stdenv, lib
, fetchFromGitHub, buildLinux
, argsOverride ? {}
, modDirVersionArg ? null
, ... } @ args:

(callPackage ./mobile-nixos/kernel/builder.nix {}) rec {
  version = "5.9.0";
  configfile = ./rotox.kernel.config;

  src = fetchFromGitHub {
    owner = "ayufan-rock64";
    repo = "linux-mainline-kernel";
    rev = "${version}-1146-ayufan";
    sha256 = "sha256-GJneuZrgQU28/pOGU5VY5VJx+cm+8BAdnXGiOzvcaI0=";
  };
  postInstall = ''
    echo ":: Installing FDTs"
    mkdir -p $out/dtbs/rockchip
    cp -v "$buildRoot/arch/arm64/boot/dts/rockchip/*" "$out/dtbs/rockchip/"
  '';

  isModular = false;
  isCompressed = false;

  systemBuild-structuredConfig = {
    ## platform extension
    CRYPTO_AEGIS128_SIMD = no;
    RTC_DRV_RK808 = yes;
    STAGING = yes;
    STAGING_MEDIA = yes;
    ARCH_ROCKCHIP = yes;
    VIDEO_DEV = module;
    VIDEO_V4L2 = module;
    MEDIA_CONTROLLER = yes;
    MEDIA_CONTROLLER_REQUEST_API = yes;
    VIDEO_HANTRO = module;
    VIDEO_HANTRO_ROCKCHIP = yes;
    ## platform restriction
    DRM_RADEON = no;
    DRM_AMDGPU = no;
    DRM_NOUVEAU = no;
    ## swraid nixos module needs md_mod
    # BLK_DEV_MD = module;
  };
}

# buildLinux (args // rec {
#   version = src.rev;
#   modDirVersion = "5.9.0";
#   extraMeta.branch = "ayufan";

#   # src = fetchFromGitLab {
#   #   domain = "gitlab.manjaro.org";
#   #   owner = "tsys";
#   #   repo = "linux-pinebook-pro";
#   #   rev = "c04087388bdb7d79d5202ffb91aa387e36901056";
#   #   sha256 = "0igxbq8i0z6qs1kxxxs440d1n1j5p5a26lgcn7q5k82rdjqhwpw9";
#   # };

#   src = fetchFromGitHub {
#     owner = "ayufan-rock64";
#     repo = "linux-mainline-kernel";
#     rev = "${modDirVersion}-1146-${extraMeta.branch}";
#     sha256 = "sha256-GJneuZrgQU28/pOGU5VY5VJx+cm+8BAdnXGiOzvcaI0=";
#   };

#   defconfig = "rockchip_linux_defconfig";

#   ## disable default configuration
#   # addCommonStructuredConfig = false;
#   # autoModules = true;
#   # extraPlatformConfig = "";

#   structuredExtraConfig = with lib.kernel; {
#     ## platform extension
#     CRYPTO_AEGIS128_SIMD = no;
#     RTC_DRV_RK808 = yes;
#     STAGING = yes;
#     STAGING_MEDIA = yes;
#     ARCH_ROCKCHIP = yes;
#     VIDEO_DEV = module;
#     VIDEO_V4L2 = module;
#     MEDIA_CONTROLLER = yes;
#     MEDIA_CONTROLLER_REQUEST_API = yes;
#     VIDEO_HANTRO = module;
#     VIDEO_HANTRO_ROCKCHIP = yes;
#     ## platform restriction
#     DRM_RADEON = no;
#     DRM_AMDGPU = no;
#     DRM_NOUVEAU = no;
#     ## swraid nixos module needs md_mod
#     # BLK_DEV_MD = module;
#   };
# } // argsOverride)
