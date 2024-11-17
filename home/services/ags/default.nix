{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  requiredDeps = with pkgs; [
    config.wayland.windowManager.hyprland.package
    bash
    coreutils
    dart-sass
    gawk
    imagemagick
    inotify-tools
    procps
    ripgrep
    util-linux
  ];

  guiDeps = with pkgs; [
    gnome-control-center
    mission-center
    overskride
    wlogout
  ];

  dependencies = requiredDeps ++ guiDeps;

  cfg = config.programs.ags;
in {
  imports = [
    inputs.ags.homeManagerModules.default
  ];

 # home.packages = dependencies;

  programs.ags.enable = true;

  #programs.ags.configDir = ../ags;

  #programs.ags.extraPackages = dependencies;
  # programs.ags = {
  #   enable = true;
  # #  configDir =../ags; #config.lib.file.mkOutOfStoreSymlink /home/david/Documents/dotfiles/home/services/ags; 
  #   extraPackages = dependencies;
  #   systemd.enable = true;
  # };
  #home.file.".cache/ags/options-nix.json".text = (builtins.toJSON agsOptions);


  systemd.user.services.ags = {
    Unit = {
      Description = "Aylur's Gtk Shell";
      PartOf = [
        "tray.target"
        "graphical-session.target"
      ];
      After = "graphical-session.target";
    };
    Service = {
      Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies}";
      ExecStart = "${cfg.package}/bin/ags";
      Restart = "on-failure";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
