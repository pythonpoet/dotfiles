# ~/nixos-config/plymouth-theme.nix
{
  pkgs,
  stdenv,
  ...
}:
stdenv.mkDerivation rec {
  pname = "oroborus";
  version = "1.0";

  src = builtins.path { path = ./oroborus; };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/plymouth/themes/${pname}
    cp -r $src/* $out/share/plymouth/themes/${pname}
  '';
}
