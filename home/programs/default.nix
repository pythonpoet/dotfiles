{
  pkgs,
  inputs,
  lib,
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
    ./devtools/zed.nix
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

    libgda5
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
    alacritty
    inkscape
    meld
    element-desktop
    libinput
    v4l-utils
    webtorrent_desktop
    popcorntime

    R
    elixir_1_18
    nodejs_20
    inotify-tools
    postgresql_17
    flyctl
    openssl

    gephi
    zulu11
    immich-cli
    brave
    # fluffychat
    baobab
    # wl-clipboard-rs
  ];

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/input-sources" = {
        show-all-sources = true;
        sources = [["xkb" "ch"]];
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
}
