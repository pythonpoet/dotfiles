{pkgs, ...}: {
  #imports = [ ./owncloud-client.nix ];
  services.owncloud-client = {
    enable = true;
    # package = pkgs.owncloud-client.overrideAttrs (oldAttrs: {
    #   src = pkgs.fetchFromGitHub {
    #     owner = "owncloud";
    #     repo = "client";
    #     rev = "v5.3.2";
    #     hash = "sha256-HEnjtedmdNJTpc/PmEyoEsLGUydFkVF3UAsSdzQ4L1Q=";
    #   };
    # });
  };
}
