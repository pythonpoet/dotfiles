{ pkgs, ... }:
{
  imports = [
    ./fonts.nix
    ./home-manager.nix
    # ./qt.nix
    ./xdg.nix
  ];

  programs = {
    # make HM-managed GTK stuff work
    dconf.enable = true;

    kdeconnect.enable = true;

    seahorse.enable = true;
    nix-ld = {
      enable = true;
        libraries = with pkgs; [
          zlib zstd stdenv.cc.cc curl openssl attr libssh bzip2 libxml2 acl libsodium util-linux xz systemd
        ];
    };
  };
}
