{ config, pkgs, lib, ... }:
{
  # nixpkgs.overlays = [
  #   (self: super: rec {
  #     pythonldlibpath = lib.makeLibraryPath (with super; [
  #       zlib zstd stdenv.cc.cc stdenv.cc.lib # <-- ADD THIS
  #       curl openssl attr libssh bzip2 libxml2 acl libsodium util-linux xz systemd
  #     ]);

  #     python = super.stdenv.mkDerivation {
  #       name = "python";
  #       buildInputs = [ super.makeWrapper ];
  #       src = super.python311;
  #       installPhase = ''
  #         mkdir -p $out/bin
  #         cp -r $src/* $out/
  #         wrapProgram $out/bin/python3 --set LD_LIBRARY_PATH ${pythonldlibpath}
  #         wrapProgram $out/bin/python3.11 --set LD_LIBRARY_PATH ${pythonldlibpath}
  #       '';
  #     };

  #     poetry = super.stdenv.mkDerivation {
  #       name = "poetry";
  #       buildInputs = [ super.makeWrapper ];
  #       src = super.poetry;
  #       installPhase = ''
  #         mkdir -p $out/bin
  #         cp -r $src/* $out/
  #         wrapProgram $out/bin/poetry --set LD_LIBRARY_PATH ${pythonldlibpath}
  #       '';
  #     };
  #     uv = super.stdenv.mkDerivation {
  #       name = "uv";
  #       buildInputs = [ super.makeWrapper ];
  #       src = super.uv;
  #       installPhase = ''
  #         mkdir -p $out/bin
  #         cp -r $src/* $out/
  #         wrapProgram $out/bin/uv --set LD_LIBRARY_PATH ${pythonldlibpath}
  #       '';
  #     };
  #   })
  # ];

  home.packages = with pkgs; [
    #python311
    poetry
    uv
  ];
}
