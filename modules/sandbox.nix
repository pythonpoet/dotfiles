# Switch to incus!
# https://wiki.nixos.org/wiki/Incus
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.sandbox;
in {
  options.sandbox = {
    enable = mkEnableOption "Enable Sandbox nixos distribution";

    image = mkOption {
      type = types.str;
      default = "nixos/nix";
    };
    port = mkOption {
      type = types.port;
      default = 8124;
    };
  };
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [cfg.port];
    #networking.firewall.extraAllowedTCPPorts = [ cfg.port ];
    networking.nat.enable = true;
    containers = {
      sandbox = {
        autoStart = true;
        hostAddress = "172.20.0.2"; # IP of the container (can be adjusted)
        forwardPorts = [
          {
            containerPort = cfg.port;
            hostPort = cfg.port;
          }
        ];

        bindMounts = {
          "/nix" = {
            hostPath = "/var/lib/containers/sandbox/nix";
            isReadOnly = false;
          };
          "/etc/nixos" = {
            hostPath = "/var/lib/containers/sandbox/config";
            isReadOnly = false;
          };
        };

        config = "/var/lib/containers/sandbox/config/configuration.nix";
      };
    };
  };
}
