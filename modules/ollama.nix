{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.llm;
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
    # services.ollama = {
    #   enable = true;
    #   acceleration = "cuda";
    #   loadModels = cfg.models;
    #   package = pkgs.callPackage ./ollama_package.nix {};
    #   # package = pkgs.ollama.overrideAttrs (oldAttrs: {
    #   #   src = fetchFromGitHub {
    #   #       owner = "ollama";
    #   #       repo = "ollama";
    #   #       tag = "v${version}";
    #   #       hash = "sha256-DW7gHNyW1ML8kqgMFsqTxS/30bjNlWmYmeov2/uZn00=";
    #   #       fetchSubmodules = true;
    #   #     };

    #   # });

    #   #gport = cfg.port_ollama;
    #   openFirewall = true;
    # };
    virtualisation.podman.enableNvidia = true;
    environment.systemPackages = [
      pkgs.nvidia-container-toolkit
    ];
    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        web-llm = {
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
          #extraOptions =
          #[ "--network=host" "--add-host=host.containers.internal:host-gateway" ];
          extraOptions = [
            "--network=host"
            "--add-host=host.containers.internal:host-gateway"
          ];
        };
        ollama = {
          image = "ollama/ollama";
          volumes = [
            "/var/lib/ollama:/root/.ollama"
          ];
          ports = [
            "11434:11434"
          ];
        };
      };
    };
    networking.firewall.allowedTCPPorts = [cfg.port_web_ui];
  };
}
