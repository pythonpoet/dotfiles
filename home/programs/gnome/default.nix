{pkgs, inputs, ...}: {
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
 home-manager.users.david = 
    let
      # Define the packages here so they are in scope for the 'david' module
      opencloud-nautilus = pkgs.opencloud-desktop-shell-integration-nautilus;
      opencloud-resources = pkgs.opencloud-desktop-shell-integration-resources;

      nautEnv = pkgs.buildEnv {
        name = "nautilus-env";
        paths = with pkgs; [
          nautilus
          nautilus-python
          gvfs
          opencloud-nautilus
          opencloud-resources
          (python3.withPackages (p: with p; [ 
            nautilus-open-any-terminal 
            pygobject3 
          ]))
        ];
      };
    in {
      # Now the 'david' attribute set starts
      home.packages = [ nautEnv ];

      home.sessionVariables = {
        NAUTILUS_4_EXTENSION_DIR = "${nautEnv}/lib/nautilus/extensions-4";
        NAUTILUS_PYTHON_PATH = "${nautEnv}/share/nautilus-python/extensions";
        XDG_DATA_DIRS = "$XDG_DATA_DIRS:${nautEnv}/share";
        GIO_EXTRA_MODULES = "${nautEnv}/lib/gio/modules";
      };

      dconf = {
        enable = true;
        settings = {
          "org/gnome/shell" = {
            disable-user-extensions = false;
            enabled-extensions = with pkgs.gnomeExtensions; [
              blur-my-shell.extensionUuid
              tiling-shell.extensionUuid
              system-monitor.extensionUuid
              pano.extensionUuid
            ];
          };
          "org/gnome/desktop/interface".color-scheme = "prefer-dark";
          "org/gnome/desktop/wm/preferences"."button-layout" = ":minimize,maximize,close";
        };
      };
    };
}
