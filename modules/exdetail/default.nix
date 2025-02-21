{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.exDetail;
in {
  options = {
    exDetail = {
      enable = mkEnableOption "Enable ExDetail";

      enable_rvtExporter = mkOption {
        type = types.bool;
        default = false;
        description = "RevitExporter enable";
      };
    };

    # Ensure rvtExporter is properly defined before usage
    rvtExporter = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable rvtExporter";
      };
    };
  };

  # FIX: Move module imports to 'imports'
  imports = [
    ./revit_converter.nix
    ./elixir-server.nix
  ];

  config = mkIf cfg.enable {
    rvtExporter.enable = cfg.enable_rvtExporter;
  };
}
