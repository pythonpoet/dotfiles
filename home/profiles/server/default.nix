{inputs, ...}: {
  imports = [
    ../../editors/helix
    ../../environment/python.nix

    inputs.catppuccin.homeManagerModules.catppuccin
  ];
}
