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
    admin_token = mkOption {
      type = types.str;
      default = "c5574019f9ad4be18b7d10bb82dae4d7200652dcae9829216a9e2844ee0fdd9d";
    };
  };
  config = mkIf cfg.enable {
    # Virtualisation config for OCI containers
    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        vaultwarden = {
          image = cfg.image;
          ports = ["${toString cfg.port}:80"];

          volumes = [
            "${cfg.data_dir}:/data/"
          ];

          environment = {
            DOMAIN = cfg.domain;
            SIGNUPS_ALLOWED = toString cfg.signups_allowed;
            ADMIN_TOKEN = cfg.admin_token;
          };
        };
      };
    };
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
