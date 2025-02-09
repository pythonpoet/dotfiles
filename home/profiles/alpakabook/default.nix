{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  hyprlandConfig = {
    imports = [
      ../../programs/wayland

      # ../../programs/hyprland.nix
      ../../services/wayland/gammastep.nix
      ../../services/wayland/hyprpaper.nix
      ../../services/wayland/hypridle.nix
      ../../services/wayland/wluma.nix
    ];

    # Set session variable for tracking
    home.sessionVariables.HOME_MANAGER_PROFILE = "hyprland";
  };

  gnomeConfig = {
    imports = [
      ../../programs/gnome
    ];

    home.sessionVariables.HOME_MANAGER_PROFILE = "gnome";
  };
in {
  home.username = "david";
  home.homeDirectory = "/home/david";
  home.stateVersion = "24.11";

  # Specialisation definitions
  specialisation = {
    hyprland.configuration = hyprlandConfig;
    #gnome.configuration = gnomeConfig;
  };

  # General imports (always enabled)
  imports = [
    ../../editors/helix
    ../../programs
    ../../services/ags
    ../../services/system/kdeconnect.nix
    ../../services/system/polkit-agent.nix
    ../../services/system/power-monitor.nix
    ../../services/system/syncthing.nix
    ../../services/system/theme.nix
    ../../services/system/udiskie.nix
    inputs.catppuccin.homeManagerModules.catppuccin
    ../../terminal/emulators/foot.nix
    ../../terminal/emulators/wezterm.nix
  ];

  # Enable Home Manager
  programs.home-manager.enable = true;
}
