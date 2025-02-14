{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.llm;
  ollamaPackage = pkgs.stdenv.mkDerivation {
    pname = "ollama";
    version = "0.1.15";
    src = cfg.package; # Use the fetched GitHub source
    #buildInputs = if cfg.acceleration == "cuda" then [ pkgs.cudaPackages ] else [];
    installPhase = ''
      mkdir -p $out/bin
      cp -r * $out/bin/
    '';
  };
in {
  options.llm = {
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
      package = ollamaPackage;
      #gport = cfg.port_ollama;
      openFirewall = true;
    };
    virtualisation.oci-containers = {
      backend = "podman";
      containers.web-llm = {
        image = cfg.image;
        ports = [
          #"${toString cfg.port_web_ui}:8080"
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
