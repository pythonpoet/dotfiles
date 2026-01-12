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
      environmentFiles = [config.age.secrets.vikunja-config.path];
      settings = {
        auth = {
          local.enabled = false;
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
      SECRET=$(cat ${config.age.secrets.vikunja-config.path})
      
      # Read from the Nix store and write to the writable path
      ${pkgs.gnused}/bin/sed "s|{client_secret}|$SECRET|g" /etc/vikunja/config.yaml \
        > ${patchedConfigPath}
        
      chmod 600 ${patchedConfigPath}
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

      # Correct command for Vikunja
      ExecStart = lib.mkForce "${cfg.package}/bin/vikunja web";

      # Your other specific settings
      ReadWritePaths = [ cfg.db_path ];
      SupplementaryGroups = [ "keys" ];
      ReadOnlyPaths = [ "/run/agenix" ];
    };
  };
    
      #environmentFiles = [ cfg.secretConfigFile ];
  #     systemd.services.vikunja = {
  # after = [ "agenix.service" ];
  
  #   serviceConfig = {
  #     # Combine all your existing settings here
  #     ReadWritePaths = [ cfg.db_path ];
  #     BindPaths = [
  #       "${cfg.db_path}:/var/lib/vikunja/"
  #     ];
  #     SupplementaryGroups = [ "keys" ];
  #     ReadOnlyPaths = [ "/run/agenix" ];

  #     # 1. The Patch Script
  #     # Note: No 'serviceConfig' nesting here!
  #     ExecStartPre = pkgs.writeShellScript "vikunja-patch-config" ''
  #       # Ensure the target file exists so the mount doesn't fail next time
  #       # and so we have a writable destination.
  #       touch /var/lib/vikunja/config.yaml

  #       # Get the secret from the age file
  #       SECRET=$(cat ${config.age.secrets.vikunja-config.path})
        
  #       # Read from the Nix store (/etc/...) and write to our writable path
  #       ${pkgs.gnused}/bin/sed "s|{client_secret}|$SECRET|g" /etc/vikunja/config.yaml \
  #       > /var/lib/vikunja/config.yaml
        
  #       chmod 600 /var/lib/vikunja/config.yaml
          
  #     '';
  #     BindReadOnlyPaths = [
  #     "/var/lib/vikunja/config.yaml:/etc/vikunja/config.yaml"
  #   ];

  #     # 2. Force Vikunja to use the patched file
  #     ExecStart = lib.mkForce "${config.services.vikunja.package}/bin/vikunja --config /var/lib/vikunja/config.patched.yaml";
  #   };
  #   };
    #environment.etc."vikunja/config.yaml".source = lib.mkForce config.age.secrets.vikunja-config.path;

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
