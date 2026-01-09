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

    # # 3. Ensure ACME certificates are world-readable or group-readable
    # security.acme.defaults.email = "no-reply@davidwild.ch";
    # security.acme.acceptTerms = true;
    # security.acme.certs."${cfg.domain}".group = "acme";
    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
                # Autoconfig for Thunderbird / Apple Mail
        locations."/.well-known/autoconfig/mail/config-v1.1.xml" = {
          alias = pkgs.writeText "config-v1.1.xml" ''
            <clientConfig version="1.1">
              <emailProvider id="${cfg.domain}">
                <domain>${cfg.domain}</domain>
                <displayName>David Wild Mail</displayName>
                <incomingServer type="imap">
                  <hostname>${cfg.domain}</hostname>
                  <port>993</port>
                  <socketType>SSL</socketType>
                  <authentication>password-cleartext</authentication>
                  <username>%EMAILADDRESS%</username>
                </incomingServer>
                <outgoingServer type="smtp">
                  <hostname>${cfg.domain}</hostname>
                  <port>465</port>
                  <socketType>SSL</socketType>
                  <authentication>password-cleartext</authentication>
                  <username>%EMAILADDRESS%</username>
                </outgoingServer>
              </emailProvider>
            </clientConfig>
          '';
        };
      };
    };
  };
}