{pkgs, ...}: {
  # Enable Gnome
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    #xkb.layout = "ch";
  };
  services.xserver = {
    xkb.layout = "ch";
  };
  # Exclude programs
  environment.gnome.excludePackages = (with pkgs; [
    atomix # puzzle game
    cheese # webcam tool
    epiphany # web browser
    #evince # document viewer
    geary # email reader
    gedit # text editor
    #gnome-characters
    gnome-music
    gnome-photos
    #gnome-terminal
    gnome-tour
    gnome-connections
    hitori # sudoku game
    iagno # go game
    tali # poker game
    totem # video player
    amberol
    simple-scan
    celluloid
]);
 home-manager.users.david = {
  dconf = {
    enable = true;
    settings = {
      
      "org/gnome/desktop/input-sources" = {
        show-all-sources = true;
        };

      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          blur-my-shell.extensionUuid
          tiling-shell.extensionUuid
          system-monitor.extensionUuid
          pano.extensionUuid
          #user-themes.extensionUuid
        ];
        disabled-extensions = [
          "dash-to-dock@micxgx.gmail.com"
          "window-list@gnome-shell-extensions.gcampax.github.com"
          "windowsNavigator@gnome-shell-extensions.gcampax.github.com"
          "light-style@gnome-shell-extensions.gcampax.github.com"
          "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
          "apps-menu@gnome-shell-extensions.gcampax.github.com"
          "emoji-copy@felipeftn"
          "native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "status-icons@gnome-shell-extensions.gcampax.github.com"
        ];
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };

      "org/gnome/desktop/wm/preferences" = {
        "button-layout" = ":minimize,maximize,close";
      };
    };
  };
 };
}
