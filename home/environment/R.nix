{pkgs, ...}: let
  python_version = "312";
in {
  home.packages = with pkgs; [
    R
    rPackages.heplots
    rPackages.IRkernel
  ];
}
