# https://vikunja.io/docs/full-docker-example/
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  # Default values
  vikunjaDefaults = {
    url = "vikunja.davidwild.ch";
    db_path = "/data1/vikunja/db";
    files_path = "/data1/vikunja/files";
    port = 3456;
  };
  cfg = config.vikunja // vikunjaDefaults;

in {
  options.vikunja = {
    enable = mkEnableOption "Enable Vikunja";
    service_jwtsecret = mkOption {
      type = types.str;
    };
    url = mkOption {
      type = types.str;
      default = "vikunja.davidwild.ch";
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
    secretConfigFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to the decrypted agenix config.yaml file.";
    };
  };

  config = mkIf cfg.enable {
    services.vikunja = {
      enable = true;
      port = cfg.port;
      frontendScheme = "https";
      frontendHostname = cfg.url;
    };
    systemd.services.vikunja = {
      serviceConfig = {
        ReadWritePaths = [ cfg.db_path  ];
        BindPaths = [
          "${cfg.db_path}:/var/lib/vikunja/"
        ];
        SupplementaryGroups = [ "keys" ];
        ExecStart = lib.mkForce "${cfg.package}/bin/vikunja";
      };
      environment = lib.mkIf (cfg.secretConfigFile != null) {
        VIKUNJA_SERVICE_CONFIGPATH = "${cfg.secretConfigFile}";
      };
    };
    # Only link the generated config to /etc if no secret config is provided
    environment.etc."vikunja/config.yaml" = lib.mkIf (cfg.secretConfigFile == null) {
      source = configFile;
    };
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
