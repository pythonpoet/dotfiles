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
    package = mkPackageOption pkgs "vikunja" { };
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
      type = types.path;
      default = config.age.secrets.vikunja-config.path;
      description = "Path to the decrypted agenix config.yaml file.";
    };
  };

  config = mkIf cfg.enable {
    services.vikunja = {
      enable = true;
      port = cfg.port;
      frontendScheme = "https";
      frontendHostname = cfg.url;
      environmentFiles = [cfg.secretConfigFile];
      settings = {
        auth = {
          local.enabled = false;
          openid = {
            enabled = true;
            providers = [
              {
                name = "Login with Authentik";
                authurl = "https://auth.davidwild.ch/application/o/vikunja"; 
                clientid = "NYytqakPqAeNuCcDmHcRcge10ADMm7o4yrxUGDau";
                clientsecret = ""; # Leave this as an empty string!
                # clientsecret = {
                #   file = config.age.secrets.vikunja-config.path;
                # };
                scope = "openid profile email";
              }
            ];
          };
        };
      };
    };
    systemd.services.vikunja = {
      serviceConfig = {
        ReadWritePaths = [ cfg.db_path  ];
        BindPaths = [
          "${cfg.db_path}:/var/lib/vikunja/"
        ];
        SupplementaryGroups = [ "keys" ];
        # This allows the dynamic user to read files owned by the 'keys' group
        environmentFiles = [ cfg.secretConfigFile ];
        ReadOnlyPaths = [ "/run/agenix" ];
      };
    };
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
