# https://vikunja.io/docs/full-docker-example/
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  # Default values
  vaultDefaults = {
    enable = true;
    storage_dir = "/var/lib/vaultwarden/";
    port = 9988;
    domain = "vault.chaosdam.net";
    docker_image = "vaultwarden/server";
    # backup = true;
  };
  cfg = config.vikunja;
in {
  options.vikunja = {
    enable = mkEnableOption "Enable Vikunja";
    image = mkOption {
      type = types.str;
      default = "vikunja/vikunja";
    };

    service_jwtsecret = mkOption {
      type = types.str;
      default = "<a super secure random secret>";
    };
    url = mkOption {
      type = types.str;
      default = "vikunja.chaosdam.net";
    };
    db_path = mkOption {
      type = types.str;
    };
    files_path = mkOption {
      type = types.str;
    };
    port = mkOption {
      type = types.port;
      default = 3456;
    };
  };

  config.vikunja = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [cfg.port];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.vikunja = {
        image = cfg.image;
        ports = ["${cfg.port}:3456"];

        volumes = [
          "${cfg.db_path}:/db"
          "${cfg.files_path}:/app/vikunja/files"
        ];

        environment = {
          VIKUNJA_SERVICE_JWTSECRET = cfg.VIKUNJA_SERVICE_PUBLICURL;

          VIKUNJA_SERVICE_PUBLICURL = cfg.url;
          # Note the default path is /app/vikunja/vikunja.db.
          # This config variable moves it to a different folder so you can use a volume and
          # store the database file outside the container so state is persisted even if the container is destroyed.
          VIKUNJA_DATABASE_PATH = "/db/vikunja.db";
        };
      };
    };
  };
}
