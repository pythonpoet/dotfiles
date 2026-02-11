{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vaultwarden;
in {
  options.vaultwarden = {
    enable = mkEnableOption "Enable Vaultwarden service";

    data_dir = mkOption {
      type = types.str;
      default = cfg.data_dir;
    };
    port = mkOption {
      type = types.port;
      default = 9968;
    };
    domain = mkOption {
      type = types.str;
      default = "vault.davidwild.ch";
    };
    signups_allowed = mkOption {
      type = types.bool;
      default = false;
    };
  };
  config = mkIf cfg.enable {
    # default config doesnt set ACME
    services.nginx.virtualHosts.${cfg.domain}.enableACME = true;
    systemd.services.vaultwarden.serviceConfig.StateDirectory = lib.mkForce cfg.data_dir;
      services.vaultwarden = {
      
      enable = true;
      configureNginx = true;
      
      domain = cfg.domain;
      

      #dataDir = lib.mkForce cfg.data_dir;
      # in order to avoid having  ADMIN_TOKEN in the nix store it can be also set with the help of an environment file
      # be aware that this file must be created by hand (or via secrets management like sops)
      environmentFile = config.age.secrets.vaultwarden.path;
      config = {
          # Refer to https://github.com/dani-garcia/vaultwarden/blob/main/.env.template
          SIGNUPS_ALLOWED = "false";

          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = cfg.port;
          ROCKET_LOG = "critical";

          DATA_FOLDER = cfg.data_dir;

          SSO_ENABLED="true";
          SSO_AUTHORITY="https://auth.davidwild.ch/application/o/vaultwarden/";

          SSO_SCOPES="email profile offline_access";
          SSO_ALLOW_UNKNOWN_EMAIL_VERIFICATION="false";
          SSO_CLIENT_CACHE_EXPIRATION="0";
          SSO_ONLY="false"; # Set to true to disable email+master password login and require SSO
          SSO_SIGNUPS_MATCH_EMAIL="true"; # Match fi

          # This example assumes a mailserver running on localhost,
          # thus without transport encryption.
          # If you use an external mail server, follow:
          #   https://github.com/dani-garcia/vaultwarden/wiki/SMTP-configuration
          SMTP_HOST = "smtp.autistici.org";
          SMTP_PORT = 587;
          SMTP_SSL = false;
          SMTP_USERNAME = "davidoff@bastardi.net";
          SMTP_SECURITY="starttls";

          SMTP_FROM = "davidoff@bastardi.net";
          SMTP_FROM_NAME = "davidwild.ch Bitwarden server";
      };
  };

    # Virtualisation config for OCI containers
    # virtualisation.oci-containers = {
    #   backend = "podman";
    #   containers = {
    #     vaultwarden = {
    #       image = cfg.image;
    #       ports = ["${toString cfg.port}:80"];

    #       volumes = [
    #         "${cfg.data_dir}:/data/"
    #       ];

    #       environment = {
    #         DOMAIN = cfg.domain;
    #         SIGNUPS_ALLOWED = toString cfg.signups_allowed;
    #         ADMIN_TOKEN = cfg.admin_token;
    #       };
    #     };
    #   };
    # };
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
