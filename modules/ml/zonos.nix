{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.zonos;
  source = pkgs.fetchFromGitHub {
    owner = "Zyphra";
    repo = "Zonos";
    rev = "main";
    sha256 = "sha256-g6N6iZrbe8XNZBe6I5KIq40+z38hJDH1Nhq8YRQ9TsA=";
  };

  zonos-image = pkgs.dockerTools.buildImage {
    name = "localhost/zonos";
    tag = "latest";
    created = "now";
    copyToRoot = pkgs.buildEnv {
      name = "zonos-root";
      paths = [source];
    };
    config = {
      WorkingDir = "${source}";
      Cmd = ["python" "gradio_interface.py"];
    };
  };
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
    # NVIDIA driver configuration
    services.xserver.videoDrivers = ["nvidia"];
    hardware.opengl.enable = true;
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Container configuration
    virtualisation.oci-containers = {
      backend = "podman";
      containers.zonos = {
        image = "localhost/zonos:latest"; # Match the built image name
        imageFile = zonos-image;
        extraOptions = [
          #"--runtime=nvidia"
          "--network=host"
          #"--gpus=all"
          "--pull=never" # Prevent trying to pull from registry
        ];
        environment = {
          NVIDIA_VISIBLE_DEVICES = "0"; #cfg.nvidiaVisibleDevices;
          GRADIO_SHARE =
            if cfg.gradioShare
            then "True"
            else "False";
        };
      };
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
