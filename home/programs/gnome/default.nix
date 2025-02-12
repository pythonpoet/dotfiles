{pkgs, ...}: {
  # Enable Gnome
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;

    #layout = services.xserver.layout;
    #xkbVariant = services.xserver.xkbVariant;
  };
}
