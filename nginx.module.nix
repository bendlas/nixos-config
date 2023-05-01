{ lib, ... }:
{

  services.nginx = {
    enable = true;
    # package = pkgs.openresty;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;

    appendHttpConfig = ''
      proxy_busy_buffers_size   256k;
      proxy_buffers   16 256k;
      proxy_buffer_size   256k;

      proxy_headers_hash_max_size 8192;
      proxy_headers_hash_bucket_size 16;

      client_body_buffer_size 256k;

      send_timeout 5m;
    '';

  };
  
  security.acme.defaults.email = lib.mkDefault "acme@bendlas.net";
  security.acme.acceptTerms = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];

}
