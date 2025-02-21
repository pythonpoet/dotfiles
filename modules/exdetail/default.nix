{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.exDetail;
in {
  options.exDetail = {
    enable = mkEnableOption "Enable ExDetail";

    enable_rvtExporter = mkOption {
      type = types.bool;
      default = false;
      description = "RevitExporter enable";
    };
  };

  config = mkIf cfg.enable {
    imports = [
      ./revit_converter.nix
      ./elixir-server.nix
    ];

    # Ensure rvtExporter is properly defined
    rvtExporter = {
      enable = cfg.enable_rvtExporter;
    };
  };
}
