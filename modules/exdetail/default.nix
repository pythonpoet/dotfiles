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

  config = mkIf cfg.enable (mkMerge [
    (import ./revit_converter.nix {inherit config pkgs lib;})
    (import ./elixir-server.nix {inherit config pkgs lib;})

    {
      rvtExporter.enable = cfg.enable_rvtExporter;
    }
  ]);
}
