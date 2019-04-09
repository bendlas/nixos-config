{ config, pkgs, ... }:

{

  nix.buildMachines = [{
    hostName = "artox.bendlas.net";
    sshUser = "root";
    sshKey = "/tmp/ssh/id_rsa";
    system = "x86_64-linux";
    maxJobs = 1;
    speedFactor = 1;
    supportedFeatures = [ ];
    mandatoryFeatures = [ ];
  }];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

}
