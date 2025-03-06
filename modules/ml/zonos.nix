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
          owner = "pythonpoet";
          repo = "Zonos";
          rev = "main";
          sha256 = "sha256-MyYUl06tgxokGcIpI+Ce0eywSlKJz+m3KjoCWle6F1E=";
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
          pkgs.git
          pkgs.gcc
        ];
        systemd.services.zonos-app = {
          enable = true;
          wantedBy = ["multi-user.target"];
          path = [pkgs.python312 pkgs.python312Packages.uv]; # Ensure uv is in the PATH

          serviceConfig = {
            WorkingDirectory = "/home/Zonos";
            Restart = "always";
            Environment = ''
              UV_PYTHON=${pkgs.python312}/bin/python3.12";

              LD_LIBRARY_PATH=/nix/store/22nxhmsfcv2q2rpkmfvzwg2w5z1l231z-gcc-13.3.0-lib/lib
              PHONEMIZER_ESPEAK_LIBRARY=${pkgs.espeak}/lib/libespeak-ng.so;
              UV_VENV=/var/lib/zonos/.venv'';
            #LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib";
            # UV_PYTHON=/nix/store/d6avn1kagr6i2n0i6b4iihxih01lgm8q-python3-3.12.8-env/bin/python3.12";
            # LD_LIBRARY_PATH=/nix/store/22nxhmsfcv2q2rpkmfvzwg2w5z1l231z-gcc-13.3.0-lib/lib;
            # PHONEMIZER_ESPEAK_LIBRARY=/nix/store/8jl206ccl80mhklh6znijr3a69dlsq3l-espeak-ng-1.51.1/lib/libespeak-ng.so;
            # UV_VENV=/var/lib/zonos/.venv'';

            # Pre-start script to sync dependencies
            ExecStartPre = [
              (pkgs.writeShellScript "copy-source" ''
                mkdir -p /home/Zonos
                cp -r ${zonosSrc}/* /home/Zonos/
                uv sync
              '')
            ];

            # Main execution command
            ExecStart = [
              (pkgs.writeShellScript "start gradio" ''
                export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib"
                uv run gradio_interface.py --port ${toString cfg.port} ${
                  if cfg.gradioShare
                  then "--share"
                  else ""
                }
              '')
            ];
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
