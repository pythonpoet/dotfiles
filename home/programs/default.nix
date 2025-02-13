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
  ];

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/input-sources" = {
        show-all-sources = true;
        sources = [
          (mkTuple ["xkb" "ch+de"])
          (mkTuple ["xkb" "us+altgr-intl"])
        ];
        xkb-options = ["terminate:ctrl_alt_bksp"];
      };

      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          blur-my-shell.extensionUuid
          tiling-shell.extensionUuid
          system-monitor.extensionUuid
          pano.extensionUuid
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

      "org/gnome/desktop/wm/preferences" = {
        "button-layout" = ":minimize,maximize,close";
      };
      # Should add macos like colour
      "gtk-config" = {
        gtk-3-css = ''@import "../macos-like-window-controls/gtk-3.0.css";'';
        gtk-4-css = ''@import "../macos-like-window-controls/gtk-4.0.css";'';
      };
      "environment.systemPackages" = [
        (pkgs.fetchzip {
          url = "https://github.com/xiadnoring/macos-like-window-controls/archive/refs/heads/main.zip";
          sha256 = ""; # Replace this with the actual hash
          stripRoot = false;
        })
      ];
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };
}
