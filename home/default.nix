{
  lib,
  self,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./specialisations.nix
    ./terminal
    inputs.nix-index-db.homeModules.nix-index
    self.nixosModules.theme
  ];

  home = {
    username = "david";
    homeDirectory = "/home/david";

    stateVersion = "24.11";
    extraOutputsToInstall = [
      "doc"
      "devdoc"
    ];
  };

  # disable manuals as nmd fails to build often
  manual = {
    html.enable = false;
  };

  # let HM manage itself when in standalone mode
  programs.home-manager.enable = true;
}
