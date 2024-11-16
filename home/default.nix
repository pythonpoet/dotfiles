{
  lib,
  self,
  inputs,
  ...
}: {
  imports = [
    ./specialisations.nix
    ./terminal
    inputs.nix-index-db.hmModules.nix-index
    # inputs.tailray.homeManagerModules.default
    self.nixosModules.theme
  ];

  home = {
    username = "david";
    homeDirectory = "/home/david";
    stateVersion = "24.05";
    extraOutputsToInstall = ["doc" "devdoc"];
  };

  # disable manuals as nmd fails to build often
  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };

  # let HM manage itself when in standalone mode
  programs.home-manager.enable = true;

  # Set catppucin falvour;
  catppuccin.flavor = "mocha";

  nixpkgs.overlays = [
    (final: prev: {
      lib = prev.lib // {colors = import "${self}/lib/colors" lib;};
    })
  ];
}
