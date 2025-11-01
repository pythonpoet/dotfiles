{inputs, ...}: {
  imports = [
    # editors
    ../../editors/helix

    # environment
    ../../environment/python.nix
    ../../environment/python-devenv.nix

    # programs
    ../../programs
    #../../programs/gnome

    # services
    #../../services/ags
    # ../../services/cinny.nix

    # media services
    # This tool is for controling music
    #../../services/media/playerctl.nix
    # ../../services/media/spotifyd.nix

    # system services
    ../../services/system/kdeconnect.nix
    #../../services/system/polkit-agent.nix
    #../../services/system/power-monitor.nix
    ../../services/system/syncthing.nix
    #../../services/system/tailray.nix
    ../../services/system/theme.nix
    ../../services/system/udiskie.nix

    # Catppuccin colors
    inputs.catppuccin.homeModules.catppuccin

    # terminal emulators
    ../../terminal/emulators/foot.nix
    ../../terminal/emulators/wezterm.nix
  ];
}
