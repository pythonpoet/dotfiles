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

    image = mkOption {
      type = types.str;
      default = "vaultwarden/server";
    };
    data_dir = mkOption {
      type = types.str;
      default = cfg.data_dir;
    };
    port = mkOption {
      type = types.port;
      default = 9988;
    };
    domain = mkOption {
      type = types.str;
      default = "vault.chaosdam.net";
    };
    signups_allowed = mkOption {
      type = types.bool;
      default = false;
    };
  };
  config = mkIf cfg.enable {
      services.vaultwarden = {
      
      enable = true;
      backupDir = "/var/local/vaultwarden/backup";
      dataDir = lib.mkForce cfg.data_dir;
      # in order to avoid having  ADMIN_TOKEN in the nix store it can be also set with the help of an environment file
      # be aware that this file must be created by hand (or via secrets management like sops)
      environmentFile = cofnig.secrets.age.vaultwarden.path;
      config = {
          # Refer to https://github.com/dani-garcia/vaultwarden/blob/main/.env.template
          DOMAIN = "https:// ${toString cfg.domain}";
          SIGNUPS_ALLOWED = false;

          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = cfg.port;
          ROCKET_LOG = "critical";

          SSO_ENABLED="true";
          SSO_AUTHORITY="https://${domain}/application/o/vaultwarden/";

          SSO_SCOPES="openid email profile offline_access";
          SSO_ALLOW_UNKNOWN_EMAIL_VERIFICATION="false";
          "SSO_CLIENT_CACHE_EXPIRATION"="0";
          SSO_ONLY="false"; # Set to true to disable email+master password login and require SSO
          SSO_SIGNUPS_MATCH_EMAIL="true"; # Match fi

          # SSO_CLIENT_ID=<client_id>
          # SSO_CLIENT_SECRET=<client_secret>

          # This example assumes a mailserver running on localhost,
          # thus without transport encryption.
          # If you use an external mail server, follow:
          #   https://github.com/dani-garcia/vaultwarden/wiki/SMTP-configuration
          # SMTP_HOST = "127.0.0.1";
          # SMTP_PORT = 25;
          # SMTP_SSL = false;

          # SMTP_FROM = "admin@bitwarden.example.com";
          # SMTP_FROM_NAME = "example.com Bitwarden server";
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
