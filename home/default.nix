{
  lib,
  self,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    #./specialisations.nix
    ./terminal
    inputs.nix-index-db.homeModules.nix-index
    self.modules.theme
    inputs.agenix.homeManagerModules.default
  ];

  home = {
    username = "david";
    homeDirectory = "/home/david";

    stateVersion = "25.05";
    extraOutputsToInstall = [
      "doc"
      "devdoc"
    ];
    sessionVariables = {
    # This assumes everyone uses the same socket location we found earlier
    SSH_AUTH_SOCK = "/home/\${user}/.bitwarden-ssh-agent.sock";
  };
};

  # disable manuals as nmd fails to build often
  manual = {
    html.enable = false;
  };

  # let HM manage itself when in standalone mode
  programs.home-manager.enable = true;
  
  age = {
    identityPaths = [ "~/.ssh/id_ed25519" ];
    secrets = {
      # example-secret = {
      #   file = ../secrets/example-secret.age;
      # };
    };
  
};
}
