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

    # Define rvtExporter option properly
    rvtExporter = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable rvtExporter";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (import ./revit_converter.nix {inherit config pkgs lib;})
    (import ./elixir-server.nix {inherit config pkgs lib;})

    {
      # Ensure rvtExporter is properly configured
      rvtExporter.enable = cfg.enable_rvtExporter;
    }
  ]);
}
