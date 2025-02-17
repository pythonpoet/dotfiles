{
  config,
  pkgs,
  lib,
  ...
}: let
  rvtPath = "/var/lib/exdetail/rvtExporter";
  # Fetch and extract RvtExporter
  rvtExporter = pkgs.stdenv.mkDerivation rec {
    pname = "rvt-exporter";
    version = "latest";

    # Fetch ZIP file from URL
    src = pkgs.fetchurl {
      url = "https://datadrivenconstruction.io/?sdm_process_download=1&download_id=1682";
      sha256 = ""; # Use `nix-prefetch-url <URL>` to get SHA256
    };

    # Unpack ZIP into mypath
    installPhase = ''
      mkdir -p $out/$rvtPath
      unzip $src -d $out/$rvtPath
    '';
  };
in {
  options.rvtExporter.enable = lib.mkEnableOption "Wine app setup for RvtExporter";

  config = lib.mkIf config.rvtExporter.enable {
    environment.systemPackages = with pkgs; [
      wineWowPackages.stable # 32-bit and 64-bit Wine support
      winetricks
      unzip
      rvtExporter # The extracted package
    ];
  };
}
