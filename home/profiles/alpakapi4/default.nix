{
  config,
  pkgs,
  inputs,
  self,
  ...
}: {
  imports = [
    ../../editors/helix/stable.nix
    ../../terminal
    inputs.catppuccin.homeModules.catppuccin
    # inputs.nix-index-db.hmModules.nix-index
    # self.nixosModules.theme
  ];
  home = {
    username = "david";
    homeDirectory = "/home/david";
    stateVersion = "24.11";
  };
  catppuccin.flavor = "mocha";
}
