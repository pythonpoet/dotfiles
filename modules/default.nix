
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
    ./audiobookshelf.nix
  ];

in
{
  flake.modules = {
    theme = import ./theme;
    cloud = cloud;
    };
}
