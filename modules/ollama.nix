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
      default = "ghcr.io/open-webui/open-webui";
    };
    db_path = mkOption {
      type = types.str;
    };
  };
  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      acceleration = "cuda";
      loadModels = cfg.models;
      port = cfg.port_ollama;
      openFirewall = true;
    };
    virtualisation.oci-containers = {
      backend = "podman";
      containers.ollama = {
        image = cfg.image;
        ports = [
          #"${toString cfg.port_web_ui}:8080"
          #"${toString cfg.port_ollama}:11434"
        ];
        volumes = [
          "${cfg.db_path}:/app/backend/data"
        ];
        environment = {
          OLLAMA_BASE_URL = "http://127.0.0.1:11434"; # Set environment variable
        };
        #comment
        extraOptions = [
          "--network=host" # Use host networking
        ];
      };
    };
    networking.firewall.allowedTCPPorts = [cfg.port_web_ui];
  };
}
