{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  emailDefaults = {
   emails = [
     "no-reply@davidwild.ch"
     "contact@davidwild.ch"
   ];
  
  domain = "mail.davidwild.ch";};
  cfg = config.email // emailDefaults;
in {
  options.email = {
    enable = mkEnableOption "Enable email";
    emails = mkOption {
      type = types.listOf types.str;
      default = cfg.emails;
    };
    domain = mkOption {
      type = types.str;
      default = cfg.domain;
    };
    
  };
  config = mkIf cfg.enable {
    services.maddy = {
      enable = true;
      hostname = "davidwild.ch";
      primaryDomain = cfg.domain;
      ensureAccounts = cfg.emails;
      openFirewall = true;
      ensureCredentials = {
        # Do not use this in production. This will make passwords world-readable
        # in the Nix store
        "no-reply@davidwild.ch".passwordFile = config.age.secrets.email.path;
        "contact@davidwild.ch".passwordFile = config.age.secrets.email.path;
      };
    };
    # 1. Give Maddy permission to read the certificates
    users.users.maddy.extraGroups = [ "acme" ];
    security.acme.certs."mail.davidwild.ch" = {
      # This doesn't overwrite your global email; it just adds these specific
      # settings to the certificate Nginx is already requesting.
      webroot = "/var/lib/acme/acme-challenge";
      group = "acme"; 
    };

    # 2. Tell Maddy where to find the Nginx-generated certificates
    services.maddy.tls = {
      loader = "file";
      certificates = [
        {
          certPath = "/var/lib/acme/${cfg.domain}/fullchain.pem";
          keyPath = "/var/lib/acme/${cfg.domain}/key.pem";
        }
      ];
    };    
    systemd.services.maddy-ensure-accounts = {
      # Wait for ACME and the main Maddy storage setup
      after = [ "acme-mail.davidwild.ch.service" "maddy.service" ];
      requires = [ "acme-mail.davidwild.ch.service" ];
      
      serviceConfig = {
        RuntimeDirectory = "maddy";
        # Ensure the script runs as the maddy user so it can access the secrets we chowned
        User = "maddy"; 
        Group = "maddy";
      };
    };
  };
}