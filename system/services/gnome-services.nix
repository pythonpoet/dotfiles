{pkgs, ...}: {
  services = {
    # needed for GNOME services outside of GNOME Desktop
    dbus.packages = with pkgs; [
      gcr
      gnome-settings-daemon
    ];

    gnome.gnome-keyring.enable = true;

    gvfs.enable = true;
    udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  };
  }
