{
  programs.zsh.enable = true;
  users = {
    extraUsers = {
      "herwig" = {
        description = "Herwig Hochleitner";
        extraGroups = [ "wheel" ];
        isNormalUser = true;
        uid = 1000;
      };
      "nara" = {
        description = "Nara Richter";
        isNormalUser = true;
        uid = 1001;
      };
      "kodi" = {
        description = "Media Center";
        isNormalUser = true;
        uid = 1002;
      };
    };
    extraGroups = { nobody = {}; };
  };
}
