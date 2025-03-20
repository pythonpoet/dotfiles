{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.kokoro;
in {
  options.kokoro = {
    enable = mkEnableOption "Enable Kokoro service";

    port = mkOption {
      type = types.port;
      default = 7861;
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
    containers.kokoro = {
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
        kokoroSrc = pkgs.fetchFromGitHub {
          owner = "thewh1teagle";
          repo = "kokoro-onnx";
          rev = "main";
          sha256 = "";
        };
      in {
        environment.systemPackages = [
          (pkgs.python312.withPackages (p:
            with p; [
              uv
            ]))
          pkgs.espeak
          pkgs.git
          pkgs.gcc
        ];
        systemd.services.kokoro-app = {
          enable = true;
          wantedBy = ["multi-user.target"];
          path = [pkgs.python312 pkgs.python312Packages.uv]; # Ensure uv is in the PATH

          serviceConfig = {
            WorkingDirectory = "/home/";
            Restart = "always";
            Environment = ''
              UV_PYTHON=${pkgs.python312}/bin/python3.12";
              LD_LIBRARY_PATH=/nix/store/22nxhmsfcv2q2rpkmfvzwg2w5z1l231z-gcc-13.3.0-lib/lib
              PHONEMIZER_ESPEAK_LIBRARY=${pkgs.espeak}/lib/libespeak-ng.so;'';

            # Pre-start script to sync dependencies
            ExecStartPre = [
              (pkgs.writeShellScript "copy-source" ''
                mkdir -p /home/Zonos
                cp -r ${kokoroSrc}/* /home/Zonos/
                uv sync
              '')
            ];

            # Main execution command
            ExecStart = [
              (pkgs.writeShellScript "start gradio" ''
                uv run examples/app.py --port ${toString cfg.port} ${
                  if cfg.gradioShare
                  then "--share"
                  else ""
                }
              '')
            ];
          };
        };
      };
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
