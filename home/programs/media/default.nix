{pkgs, ...}:
# media - control and enjoy audio/video
{
  imports = [
    ./mpv.nix
    ./rnnoise.nix
  ];

  home.packages = with pkgs; [
    # audio control
    pavucontrol
    pulsemixer

    # audio
    amberol
    spotify

    # images
    loupe

    # videos
    celluloid
  ];
}