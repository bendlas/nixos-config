{ pkgs, ... }:

{

  programs.zsh = {
    enable = true;
    shellAliases = {
      l = "lid";
    };
    interactiveShellInit = ''
      source ${./zshrc}
    '';
    promptInit = ''
      LP_PS1_FILE=${./liquidprompt.ps1}
      LP_ENABLE_TEMP=0
      source ${pkgs.callPackage ./liquidprompt.nix {}}/liquidprompt
    '';
  };

  environment.systemPackages = with pkgs; [
    zsh-capture-completion
  ];

}
