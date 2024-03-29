{ lib, config, ... }:
with lib;
with types;
{
  options.bendlas.wheel.logins = mkOption {
    default = [ "herwig" ];
    type = listOf string;
  };
  options.bendlas.wheel.keys = mkOption {
    default = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC70QgW3EnX781iFOlojPnwST1CiMZaWdQEJNgSbsvaEFeHwFNDr9Ma2kTzjFQnpLKfb7eAr7BsUX3uSJjFq6MDTfgynCSXtgOxaahTfoVFFvJdGZPtXU09k7xSW043A7Ziwi8iPM0EFKUb85W6v4S1VACpjD57SEs4enUsyrXO8XVBDpqRQLdPDXjyNqzZ0zafbs22bDYDUmgr3UTItSzrGG7fzPyP3D2cJ1HKptQNUBRwjMvduG5by+ONxtuNJ7XGtQfFOyLJl4QFCWCSNwVEzv0CqAfrbq3XmqsAMXZJeMNo0OG/XpgQT2W4oP0QcyW9hHvxe6S34DjXDCaN8SreTJqq/8n3gQIj2/bkW9gGOHceZ98BDVXAeVXQj4opd3qF1V3DkP7NhUZEpgqHZglpkmcZqiufpdJbhnbjjIAUPN9c2dpEKWiR+UTR0hUedERDEGge6caM0XpfKPDiFXQpNgMBhatRkp9iNwoCIbp1muzYZpiu8YFNFbZmRmXcW8o8b3/MoEWZZTvMcffk7Yk+K0lItLmR7wjAJVZXM/7CbP6bVECbYAGNaQ50ZlPgt1wAU9VoE9oV3U2bVmV6Vdic1w1LS3pCOT9DNOXkGvbxLxp/gwJVFwkHVBAHnSLCyRyNn3GL+rzPO0Mzej2Q9stPUExcoMBkm6e4pUatynHONw== herwig@lenix"
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3Khpm5c6frwLZeFb7KgLRlawspBbNEUyPm5181qy0Z9h1itx8d+zzAjASVFFjSqdi9lrH2+amQRGcc9b87AF7grJAwZvvasKHnmMOog9CnOvCvnPhvPucBdyBT7RB6TBWV0GAvt5UrMJHJSLbIVrSIU4GGAYwqM8HhcVlVEq53Wmx8fqOfQugPWSy72aMyQybX1XoxpL272mwLfFmxjZXpq3+VeoFLcvX/yL8as1jNnnoNFs9cwvZZMvNpB2VHzBmlyTwd9JL4nriAro3kIEtRZrEdigyP3q7fzZArvvRha3PhBF1gjBpFzFVRC2ysQ9/B8s+ljXO6Dj2ocTIi66SQ== herwig@nitox"
    ];
    type = listOf string;
  };
  config.users.users = listToAttrs
    (map (user: nameValuePair
      user {
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = config.bendlas.wheel.keys;
      }
    ) ([ "root" ] ++ config.bendlas.wheel.logins));
}
