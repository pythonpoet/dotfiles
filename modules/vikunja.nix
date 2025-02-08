# https://vikunja.io/docs/full-docker-example/
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  # Default values
  cfg =
    config.vikunja
    or {
      enable = false;
      image = "vikunja/vikunja";
      service_jwtsecret = "<a super secure random secret>";
      url = "vikunja.chaosdam.net";
      db_path = "/var/lib/vikunja/db";
      files_path = "/var/lib/vikunja/files";
      port = 3456;
    };
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

  config = mkIf cfg.enable {
    virtualisation.oci-containers = {
      backend = "podman";
      containers.vikunja = {
        image = cfg.image;
        ports = ["${toString cfg.port}:3456"];

        volumes = [
          "${cfg.db_path}:/db"
          "${cfg.files_path}:/app/vikunja/files"
        ];

        environment = {
          VIKUNJA_SERVICE_JWTSECRET = cfg.service_jwtsecret;
          VIKUNJA_SERVICE_PUBLICURL = cfg.url;
          VIKUNJA_DATABASE_PATH = "/db/vikunja.db";
        };
      };
    };
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
  # networking.firewall.allowedTCPPorts =  [ cfg.port ];
}
