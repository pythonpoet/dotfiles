{ config, pkgs, ... }:

{
  # Base path where all calendars are stored locally
  accounts.calendar.basePath = "${config.home.homeDirectory}/.calendars";

  accounts.calendar.accounts = {

    # ── 1. CalDAV calendar (e.g. Nextcloud, Radicale, Fastmail) ────────────
    "cloud.davidwild.ch" = {
      primary = true;
      remote = {
        type = "caldav";
        url = "https://cloud.davidwild.ch/caldav/";
        userName = "your-username";
        # Use a command so the password is never stored in plain text
        passwordCommand = [ "secret-tool" "lookup" "service" "cloud.davidwild.ch" "username" "david" ];
        # Alternatives: [ "pass" "caldav/password" ]
        #               [ "cat" "/run/secrets/caldav-password" ]  # sops-nix / agenix
      };
      vdirsyncer = {
        enable = true;
        collections = [ "from b" ]; # discover all collections from the server
        metadata = [ "color" "david" ];
        conflictResolution = "remote wins";
      };
    };

    
    # ── 3. Google Calendar (OAuth2) ────────────────────────────────────────
    # Requires a Google Cloud project with the Calendar API enabled.
    # Create OAuth2 credentials (Desktop app) and note the client ID + secret.
    # On first run: `vdirsyncer discover google` will open a browser for auth.
    "google" = {
      remote = {
        type = "caldav";
        url = "https://apidata.googleusercontent.com/caldav/v2/biobrotmithonig@gmail.com/user";
        userName = "biobrotmithonig@gmail.com";
      };
      vdirsyncer = {
        enable = true;
        auth = "oauth2";
        # Commands that print the OAuth2 client ID and secret to stdout
        clientIdCommand     = [ "secret-tool" "lookup" "service" "biobrotmithonig@gmail.com" "auth" "client_id" ];
        clientSecretCommand = [ "secret-tool" "lookup" "service" "biobrotmithonig@gmail.com" "auth" "client_secret" ];
        # Where vdirsyncer stores the access/refresh token after first auth
        tokenFile = "${config.xdg.dataHome}/vdirsyncer/google-token";
        collections = [ "from b" ];
        metadata = [ "color" "displayname" ];
        conflictResolution = "remote wins";
      };
    };
  };

  # ── vdirsyncer daemon + periodic sync ─────────────────────────────────────
  services.vdirsyncer = {
    enable = true;
    frequency = "*:0/15"; # sync every 15 minutes (systemd calendar expression)
  };

  # ── Optional: khal CLI calendar viewer ────────────────────────────────────
  programs.khal = {
    enable = true;
    settings = {
      default.timedelta = "7d";
      view.bold_for_light_color = false;
    };
  };
}
