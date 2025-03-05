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
          sha256 = "";
        };
      in {
        environment.systemPackages = [
          (pkgs.python312.withPackages (p:
            with p; [
              torch
              torchaudio
              # pmdarima
            ]))
          pkgs.espeak
        ];
        systemd.services.zonos-app = {
          enable = true;
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            ExecStart = "${pkgs.python312}/bin/python ${zonosSrc}/app.py --port ${toString cfg.port} ${optionalString cfg.gradioShare "--share"}";
            WorkingDirectory = zonosSrc;
            Restart = "always";
          };
          environment = {
            NVIDIA_VISIBLE_DEVICES = cfg.nvidiaVisibleDevices;
            LD_LIBRARY_PATH = "${pkgs.linuxPackages.nvidia_x11}/lib:${pkgs.cudatoolkit}/lib";
          };
        };
      };
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
