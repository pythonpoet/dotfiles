{pkgs, ...}: {
  # Enable Gnome
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;

    #layout = user.services.xserver.layout;
    #xkbVariant = user.services.xserver.xkbVariant;
  };

  # # Configure Packages
  # environment.gnome.excludePackages =
  #   (with pkgs; [
  #     gnome-photos
  #     gnome-tour
  #     gedit # text editor
  #     cheese # webcam tool
  #     gnome-music
  #     epiphany # web browser
  #     geary # email reader
  #     evince # document viewer
  #     gnome-characters
  #     totem # video player
  #     tali # poker game
  #     iagno # go game
  #     hitori # sudoku game
  #     atomix # puzzle game
  #   ])
  #   ++ (with pkgs.gnome; [
  #     gnome-terminal
  #   ]);
}
