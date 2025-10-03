let
  desktop = [
    ./core/default.nix
    ./core/boot.nix

    # ./hardware/fwupd.nix
    # ./hardware/graphics.nix

    ./network
    # TODO activate avahi
    #./network/avahi.nix
    ./network/tailscale.nix

    ./programs

    ./services
    #./services/greetd.nix
    #./services/pipewire.nix
  ];

  laptop = desktop ++ [
    ./hardware/bluetooth.nix

    ./services/power.nix
  ];
in
{
  inherit desktop laptop;
}
