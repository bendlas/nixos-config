{
  programs.zsh.enable = true;
  users = {
    extraUsers = {
      "herwig" = {
        description = "Herwig Hochleitner";
        extraGroups = [ "wheel" ];
        shell = "/run/current-system/sw/bin/zsh";
        isNormalUser = true;
        uid = 1000;
      };
      "nara" = {
        description = "Nara Richter";
        isNormalUser = true;
        uid = 1001;
      };
    };
    extraGroups = { nobody = {}; };
  };
}
