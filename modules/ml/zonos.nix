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
    rev = "main"; # or specific commit hash
    sha256 = "1h2f7la63g0s6vsk2911gz7kx3dbi2927fhpck6wayyvka4pm8w3"; # Update with actual hash
  };
in {
  options.zonos = {
    enable = mkEnableOption "Enable Zonos service";

    package = mkOption {
      type = types.package;
      default = source;
      description = "Zonos source package";
    };

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

    # Docker configuration with NVIDIA support
    virtualisation.docker = {
      enable = true;
      extraOptions = "--default-runtime=nvidia";
    };

    # Container configuration
    virtualisation.oci-containers = {
      backend = "podman";
      containers.zonos = {
        image = builtins.toString cfg.package; # Build from fetched source
        extraOptions = [
          "--runtime=nvidia"
          "--network=host"
          "--gpus=all"
        ];
        environment = {
          NVIDIA_VISIBLE_DEVICES = cfg.nvidiaVisibleDevices;
          GRADIO_SHARE =
            if cfg.gradioShare
            then "True"
            else "False";
        };
        cmd = ["python3" "gradio_interface.py"];
      };
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
