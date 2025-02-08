{
  config,
  pkgs,
  ...
}: let
  # Default values
  vaultDefaults = {
    enable = true;
    storage_dir = "/var/lib/vaultwarden/";
    port = 9988;
    domain = "vault.chaosdam.net";
    docker_image = "vaultwarden/server";
    # backup = true;
  };

  # Merge user-defined config with defaults
  vaultConfig = config.vault // vaultDefaults;
in {
  # Enable port for Vaultwarden
  networking.firewall.allowedTCPPorts = [vaultConfig.port];

  # Virtualisation config for OCI containers
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      vaultwarden = {
        # Only enable container if vault.enable is true
        enable = vaultConfig.enable;
        image = vaultConfig.docker_image;
        ports = ["${vaultConfig.port}:80"];

        volumes = [
          "${vaultConfig.storage_dir}:/data/"
        ];

        environment = {
          DOMAIN = vaultConfig.domain;
          SIGNUPS_ALLOWED = "false";
          ADMIN_TOKEN = "tocken";
        };
      };
    };
  };

  # If backup is enabled, delegate to borg.backup
  #borgBackup = if vaultConfig.backup then
  #  import ./borg.backup {
  #    storage_dir = vaultConfig.storage_dir;
  #  }
  #  else null;
}
