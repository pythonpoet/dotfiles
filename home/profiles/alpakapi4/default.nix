{ config, pkgs, ... }:

{
  home.username = "david";
  home.homeDirectory = "/home/david";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    helix
    git
  ];

  programs.git.enable = true;
  programs.zsh.enable = true;
}
