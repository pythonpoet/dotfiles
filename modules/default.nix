
let
  cloud = [
    ./borg.nix
    ./dashy.nix
    ./immich.nix
    ./incus.nix
    ./ollama.nix
    ./owncloud.nix
    ./postgresql.nix
    ./reverse-proxy.nix
    ./vaultwarden.nix
    ./vikunja.nix
    ./wireguard.nix
  ];

in
{
  flake.module = {
    theme = import ./theme;
    cloud = cloud;
    };
}
