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
    ./devtools/codium.nix
    ./owncloud-client/default.nix
  ];

  home.packages = with pkgs; [
    signal-desktop
    tdesktop

    gnome-calculator
    gnome-control-center

    overskride
    mission-center
    wineWowPackages.wayland

    bitwarden-desktop
    thunderbird
    beeper

    #inputs.nix-matlab.packages.${pkgs.system}.matlab
  ];
}
