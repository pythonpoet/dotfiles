{inputs, ...}:{
  imports = [
    ../../editors/helix

     # media services
    # This app hosts immages
    ../../services/media/immich.nix

    inputs.catppuccin.homeManagerModules.catppuccin
     ];
}
