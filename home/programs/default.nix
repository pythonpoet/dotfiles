{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./anyrun
    ./browsers/firefox.nix
    ./browsers/zen.nix
    ./media
    ./gtk.nix
    ./office
    ./qt.nix
    ./devtools
  ];

  home.packages = with pkgs; [
    signal-desktop
    tdesktop

    gnome-calculator
    gnome-control-center

    overskride
    mission-center
    wineWowPackages.wayland

    #inputs.nix-matlab.packages.${pkgs.system}.matlab
  ];

}
