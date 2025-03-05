{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.zonos;
in {
  options.zonos = {
    enable = mkEnableOption "Enable Zonos service";

    port = mkOption {
      type = types.port;
      default = 7860;
      description = "Port for Gradio web interface";
    };

    nvidiaVisibleDevices = mkOption {
      type = types.str;
      default = "all";
      description = "NVIDIA GPU devices to make available";
    };

    gradioShare = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Gradio sharing feature";
    };
  };

  config = mkIf cfg.enable {
    containers.zonos = {
      autoStart = true;
      forwardPorts = [
        {
          containerPort = cfg.port;
          hostPort = cfg.port;
          protocol = "tcp";
        }
      ];
      config = {
        pkgs,
        config,
        lib,
        ...
      }: let
        zonosSrc = pkgs.fetchFromGitHub {
          owner = "Zyphra";
          repo = "Zonos";
          rev = "main";
          sha256 = "sha256-g6N6iZrbe8XNZBe6I5KIq40+z38hJDH1Nhq8YRQ9TsA=";
        };
      in {
        environment.systemPackages = [
          (pkgs.python312.withPackages (p:
            with p; [
              torch
              torchaudio
              uv
              # pmdarima
            ]))
          pkgs.espeak
        ];
        systemd.services.zonos-app = {
          enable = true;
          wantedBy = ["multi-user.target"];
          path = ["/run/current-system/sw/bin/uv"]; # Ensure uv is in the PATH

          serviceConfig = {
            WorkingDirectory = zonosSrc;
            Restart = "always";

            # Pre-start script to sync dependencies
            ExecStartPre = ''
              uv sync
              uv sync --extra compile
              uv pip install -e .
            '';

            # Main execution command
            ExecStart = ''
              uv run gradio_interface.py --port ${toString cfg.port} ${
                if cfg.gradioShare
                then "--share"
                else ""
              }
            '';
          };
        };

        # environment = {
        #   NVIDIA_VISIBLE_DEVICES = cfg.nvidiaVisibleDevices;
        #   LD_LIBRARY_PATH = "${pkgs.linuxPackages.nvidia_x11}/lib:${pkgs.cudatoolkit}/lib";
        # };
      };
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
