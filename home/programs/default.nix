{
  pkgs,
  inputs,
  lib,
  ...
}: let
  macosLikeWindowControls = pkgs.fetchzip {
    url = "https://github.com/xiadnoring/macos-like-window-controls/archive/refs/heads/main.zip";
    sha256 = "sha256-ja7BrL48vOEBUqQz3LstaW5GBY3pboU2oMFDynF6lXk="; # Replace with actual hash
    stripRoot = false;
  };
in {
  imports = [
    ./anyrun
    ./browsers/firefox.nix
    ./browsers/zen.nix
    ./media
    ./gtk.nix
    ./office
    ./qt.nix
    ./devtools/codium.nix
  ];

  home.packages = with pkgs; [
    signal-desktop
    tdesktop

    gnome-calculator
    gnome-control-center

    gnomeExtensions.system-monitor
    gnomeExtensions.blur-my-shell
    gnomeExtensions.tiling-shell
    gnomeExtensions.pano
    gnomeExtensions.user-themes
    whitesur-gtk-theme
    whitesur-icon-theme
    libgda
    gsound

    overskride
    mission-center
    wineWowPackages.wayland

    bitwarden-desktop
    thunderbird
    beeper
    newsflash
    anki
    typst
    glow
    zotero
    owncloud-client
    dconf-editor
    zed-editor

    # programming
    # pythonPackages.python
    python312Full
    python312Packages.ipykernel
    python312Packages.jupyterlab
    python312Packages.notebook
    poetry
    python312Packages.pip
    python312Packages.numpy
    python312Packages.pandas
    python312Packages.requests
  ];

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/input-sources" = {
        show-all-sources = true;
        sources = [
          ["xkb" "ch"]
        ];
        #xkb-options = ["terminate:ctrl_alt_bksp"];
      };

      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          blur-my-shell.extensionUuid
          tiling-shell.extensionUuid
          system-monitor.extensionUuid
          pano.extensionUuid
          user-themes.extensionUuid
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
        gtk-theme = "WhiteSur-Dark";
        icon-theme = "WhiteSur";
        color-scheme = "prefer-dark";
      };

      "org/gnome/desktop/wm/preferences" = {
        "button-layout" = ":minimize,maximize,close";
      };
    };
  };
}
