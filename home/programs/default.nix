{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    #./anyrun
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
  alacritty
  anki
  agenix-cli
  baobab
  beeper
  bitwarden-desktop
  brave
  ente-auth
  calibre
  cheese
  dconf-editor
  elixir_1_18
  element-desktop
  gephi
  glow
  gnome-calculator
  gnome-control-center
  gnomeExtensions.blur-my-shell
  gnomeExtensions.pano
  gnomeExtensions.system-monitor
  gnomeExtensions.tiling-shell
  gnomeExtensions.user-themes
  gnome-software
  gsound
  halloy
  immich-cli
  inkscape
  inotify-tools
  meld
  mission-center
  newsflash
  nodejs_20
  openssl
  owncloud-client
  overskride
  geckodriver
  #flatpak
  popcorntime
  postgresql_17
  R
  readest
  resources
  signal-desktop
  telegram-desktop
  thunderbird
  typst
  v4l-utils
  webtorrent_desktop
  wineWowPackages.wayland
  weka
  zotero
  zulu11
];


  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/input-sources" = {
        show-all-sources = true;
        sources = [
          [
            "xkb"
            "ch"
          ]
        ];
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
