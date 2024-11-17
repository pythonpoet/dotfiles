{
  config,
  pkgs,
  ...
}: let
  shyfox = pkgs.fetchFromGitHub {
    owner = "Naezr";
    repo = "ShyFox";
    rev = "6488ff1934c184a7b81770c67f5c3b5e983152e3";
    hash = "sha256-9InO33jS+YP+aupQc8OadvGSyXEIBcTbN8kTo91hAbY=";
  };
in {
  programs.firefox = {
    enable = true;
    profiles.david = {
      settings = {
        "apz.overscroll.enabled" = true;
        "browser.aboutConfig.showWarning" = false;
        "general.autoScroll" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      #extraConfig = builtins.readFile "${shyfox}/user.js";
    };
  };

  #home.file.".mozilla/firefox/${config.programs.firefox.profiles.david.path}/chrome".source = "${shyfox}/chrome";
}
