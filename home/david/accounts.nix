{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ vdirsyncer khal libsecret ];

  # ── khal ──────────────────────────────────────────────────────────────────
  home.file.".config/vdirsyncer/config".source =~/Documents/dotfiles/home/david/vdirsyncer;
  home.file.".config/khal/config".source =~/Documents/dotfiles/home/david/config;
  # home.file."home/david/Documents/dotfiles/home/david/config".source ="home/david/Documents/dotfiles/.config/khal/config";
  # home.file."vdirsync".source ="home/david/Documents/dotfiles.config/vdirsync/config";
  programs.khal = {
    enable = true;
    # settings = {
    #     default_calendar = pkgs.lib.mkForce "991722ac-4c42-4236-aeaf-7d1cfe78f30f";
    #     timedelta = "7d";
    #     highlight_event_days = true;
    #   };
    #   locale = {
    #     timeformat = "%H:%M";
    #     dateformat = "%Y-%m-%d";
    #     longdateformat = "%Y-%m-%d";
    #     datetimeformat = "%Y-%m-%d %H:%M";
    #     longdatetimeformat = "%Y-%m-%d %H:%M";
    #     firstweekday = 0; # 0 = Monday, 6 = Sunday
    #   };
    #   view = {
    #     frame = "color";
    #     bold_for_light_color = false;
    #   };
    # };
  };

  # ── vdirsyncer systemd timer ──────────────────────────────────────────────
  programs.vdirsyncer.enable = true;
  services.vdirsyncer = {
    
    enable = true;
    frequency = "*:0/15"; # every 15 minutes
  };

  # ── Calendars ─────────────────────────────────────────────────────────────
  # accounts.calendar = {
  #   basePath = ".calendars";

  #   accounts."caldav" = {
  #     primary = true;

  #     local.type = "filesystem";
  #     local.fileExt = ".ics";

  #     remote.type = "caldav";
  #     remote.url = "https://cloud.davidwild.ch/caldav/";
  #     remote.userName = "david";
  #     remote.passwordCommand = [
  #       "secret-tool" "lookup"
  #       "service" "cloud.davidwild.ch"
  #       "username" "david"
  #     ];

  #     vdirsyncer.enable = true;
  #     vdirsyncer.collections = [ "from a" "from b" ]; # Use the display names found in your discover output
  #     vdirsyncer.itemTypes = [ "VEVENT" ];
  #     vdirsyncer.metadata = [ "displayname" "color" ];
  #     vdirsyncer.conflictResolution = "remote wins";

  #     khal.enable = true;
  #     khal.color = "light blue";
  #     khal.type = "discover";
  #   };

  #   accounts.google = {
  #     local.type = "filesystem";
  #     local.fileExt = ".ics";

  #     remote.type = "caldav";
  #     # vdirsyncer will discover the correct path via OAuth2
  #     remote.url = "https://apidata.googleusercontent.com/caldav/v2/";
  #     remote.userName = "biobrotmithonig@gmail.com";

  #     vdirsyncer.enable = true;
  #     vdirsyncer.collections = [ "from b" ];
  #     vdirsyncer.itemTypes = [ "VEVENT" ];
  #     vdirsyncer.metadata = [ "displayname" "color" ];
  #     vdirsyncer.conflictResolution = "remote wins";
  #     # OAuth2 — store tokens and credentials via secret-tool
  #     # On first run: vdirsyncer discover google  (opens browser)
  #     vdirsyncer.auth =  "oauth2";
      
  #     vdirsyncer.clientIdCommand = [
  #       "secret-tool" "lookup"
  #       "service" "biobrotmithonig@gmail.com"
  #       "auth" "client_id"
  #     ];
  #     vdirsyncer.clientSecretCommand = [
  #       "secret-tool" "lookup"
  #       "service" "biobrotmithonig@gmail.com"
  #       "auth" "client_secret"
  #     ];
  #     vdirsyncer.tokenFile = "${config.xdg.dataHome}/vdirsyncer/google-token";

  #     khal.enable = true;
  #     khal.color = "light green";
  #     khal.type = "discover";
  #   };
  # };
}
