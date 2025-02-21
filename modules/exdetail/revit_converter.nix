{
  config,
  pkgs,
  lib,
  ...
}: let
  # Fetch and extract RvtExporter directly into the Nix store
  rvtExporter = pkgs.stdenv.mkDerivation rec {
    pname = "rvt-exporter";
    version = "latest";

    src = pkgs.fetchurl {
      url = "https://datadrivenconstruction.io/?sdm_process_download=1&download_id=1682";
      sha256 = "sha256-+NWOuZBJnyOJyXlGmPkg2yOJI3S+Qi9N0yVP8sbJFYg="; # Run `nix-prefetch-url <URL>` to get SHA256
    };

    nativeBuildInputs = [pkgs.unzip]; # Ensure unzip is available

    # Fix unpacking by renaming the source
    unpackPhase = ''
      cp $src rvt-exporter.zip
      unzip -o rvt-exporter.zip -d extracted
    '';

    installPhase = ''
      mkdir -p $out
      cp -r extracted/* $out/
    '';
  };
in {
  config = lib.mkIf config.rvtExporter.enable {
    environment.systemPackages = with pkgs; [
      wineWowPackages.stable # Wine for Windows apps
      winetricks
      unzip
      rvtExporter # The extracted package in the Nix store
    ];
  };
}
