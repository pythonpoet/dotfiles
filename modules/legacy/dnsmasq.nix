{
  config,
  pkgs,
  ...
}: {
  services.dnsmasq.enable = true;
  services.dnsmasq.settings.interface = ["wg0"];
}
