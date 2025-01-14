{
  inputs,
  pkgs,
  ...
}: {
  
#imports = [./languages.nix];

  programs.helix = {
    enable = true;
#    package = inputs.helix.packages.${pkgs.system}.default;
    extraPackages = with pkgs; [
#      markdown-oxide
 #     nodePackages.vscode-langservers-extracted
#      shellcheck
   ];#
  };
}
