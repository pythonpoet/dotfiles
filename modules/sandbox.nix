{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.sandbox;
in {
  options.sandbox = {
    enable = mkOptionEnable "Enable Sandbox nixos distribution";

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
    virtualisation.oci-containers = {
      backend = "podman";
      containers.sandbox = {
        image = cfg.image;
        ports = ["${toString cfg.port}:22"];
      };
    };
  };
}
