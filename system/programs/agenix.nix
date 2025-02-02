{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  environment.systemPackages = [
    inputs.agenix.packages."${config.nixpkgs.system}".default
  ];
}
