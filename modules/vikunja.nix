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
    db_path = "/data1/vikunja/db/vikunja.db";
    files_path = "/data1/vikunja/files";
    port = 3456;
  };
  patchedConfigPath = "/var/lib/vikunja/config.patched.yaml";
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
      environmentFiles = [config.age.secrets.vikunja-config.path];
      settings = {
        service = {
          enableregistration = false;
          JWTSecret = "{jwt_secret}";
        };
        auth = {
          local.enabled = true;
          openid = {
            enabled = true;
            providers = [
              {
                name = "Login with Authentik";
                authurl = "https://auth.davidwild.ch/application/o/vikunja/"; 
                clientid = "NYytqakPqAeNuCcDmHcRcge10ADMm7o4yrxUGDau";
                clientsecret = "{client_secret}";
                scope = "openid profile email";
              }
            ];
          };
        };
        database.path = lib.mkForce "/data1/vikunja/db/vikunja.db";
        files.basepath = lib.mkForce cfg.files_path;
      };
    };
    # 1. Create a "Setup" service to handle the secret injection
  systemd.services.vikunja-config-setup = {
    description = "Prepare patched Vikunja config with secrets";
    wantedBy = [ "multi-user.target" ];
    before = [ "vikunja.service" ];
    after = [ "agenix.service" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Run as root to ensure we can create directories and read secrets
      User = "root"; 
      # Ensures /var/lib/vikunja exists
      StateDirectory = "vikunja"; 
    };

    script = ''
      source ${config.age.secrets.vikunja-config.path}

      ${pkgs.gnused}/bin/sed -e "s|{client_secret}|$client_secret|g" \
                            -e "s|{jwt_secret}|$jwt_secret|g" \
                            /etc/vikunja/config.yaml > ${patchedConfigPath}
      # SECRET=$(cat ${config.age.secrets.vikunja-config.path})
      
      # # Read from the Nix store and write to the writable path
      # ${pkgs.gnused}/bin/sed "s|{client_secret}|$SECRET|g" /etc/vikunja/config.yaml \
      #   > ${patchedConfigPath}
        
      chmod 644 ${patchedConfigPath}
    '';
  };

  # 2. Update the main Vikunja service
  systemd.services.vikunja = {
    # Ensure it waits for our setup service
    wants = [ "vikunja-config-setup.service" ];
    after = [ "vikunja-config-setup.service" ];

    serviceConfig = {
      # Now the file definitely exists, so BindReadOnlyPaths will NOT fail
      
      BindReadOnlyPaths = [
        "${patchedConfigPath}:/etc/vikunja/config.yaml"
      ];
      StateDirectory = "vikunja";

      # Correct command for Vikunja
      ExecStart = lib.mkForce "${cfg.package}/bin/vikunja web";

      # Your other specific settings
      ReadWritePaths = [ cfg.db_path ];
      SupplementaryGroups = [ "keys" ];
      ReadOnlyPaths = [ "/run/agenix" ];
    };
  };
    
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
