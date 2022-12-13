{

  programs.steam.enable = true;

  ## prevent NM auth dialogs
  ## see https://github.com/ValveSoftware/steam-for-linux/issues/7856#issuecomment-1327053152
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id === "org.freedesktop.NetworkManager.settings.modify.system") {
        var name = polkit.spawn(["cat", "/proc/" + subject.pid + "/comm"]);
        if (name.includes("steam")) {
          polkit.log("ignoring steam NM prompt");
          return polkit.Result.NO;
        }
      }
    });
  '';

}
