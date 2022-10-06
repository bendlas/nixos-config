{ lib, ... }:
{

  services.nginx = {
    enable = true;
    recommendedProxySettings = true; 
  };
  
  security.acme.email = lib.mkDefault "acme@bendlas.net";
  security.acme.acceptTerms = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];

}