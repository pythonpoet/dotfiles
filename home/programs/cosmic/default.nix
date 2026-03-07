{inputs, ...}:{
  imports = [
    inputs.cosmic-manager.homeManagerModules.cosmic-manager
  ];
  wayland.desktopManager.cosmic.enable = true;
}