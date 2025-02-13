{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.ollama;
in {
  options.ollama = {
    enable = mkEnableOption "Enable Ollama";
    models = mkOption {
      type = types.listOf types.str;
    };
    port_ollama = mkOption {
      type = types.port;
      default = 11434;
    };
    port_web_ui = mkOption {
      type = types.port;
      default = 3000;
    };
    image = mkOption {
      type = types.str;
      default = "ghcr.io/open-webui/open-webui:main";
    };
    # Path
    db_path = mkOption {
      type = types.str;
    };
  };
  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      acceleration = "cuda";
      loadModels = cfg.models;
    };
    virtualisation.oci-containers = {
      backend = "podman";
      containers.ollama = {
        image = cfg.image;
        ports = ["${toString cfg.port}:8080"];

        volumes = [
          "${cfg.db_path}:/app/backend/data"
        ];
        environment = {
          extra_params = "--add-host=host.docker.internal:host-gateway";
        };
      };
    };
    networking.firewall.allowedTCPPorts = [cfg.port_web_ui];
  };
}
