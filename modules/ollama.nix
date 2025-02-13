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
          "${toString cfg.port_web_ui}:8080"
          #"${toString cfg.port_ollama}:11434"
        ];

        volumes = [
          "${cfg.db_path}:/app/backend/data"
        ];
        #comment
        #extraOptions = ["-add-host=host.docker.internal:host-gateway"];
      };
    };
    networking.firewall.allowedTCPPorts = [cfg.port_web_ui];
  };
}
