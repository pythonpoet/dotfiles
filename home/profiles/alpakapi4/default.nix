{ config, pkgs,inputs, ... }:
{
  imports = [

    ../../editors/helix/stable.nix
    inputs.catppuccin.homeManagerModules.catppuccin
  ];
}
