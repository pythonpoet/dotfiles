{pkgs, ...}: {
  home.packages = with pkgs; [
    # archives
    zip
    unzip
    unrar

    # misc
    libnotify

    # utils
    dust
    duf
    fd
    file
    jaq
    ripgrep
    tmux
  ];

  programs.eza.enable = true;
}
