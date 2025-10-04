# networking configuration
{pkgs, ...}: {
    environment.systemPackages =  [pkgs.geteduroam-cli];

  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
  };

  services = {
    openssh = {
      enable = true;
      settings.UseDns = true;
    };

    # DNS resolver
    resolved = {
      enable = true;
      dnsovertls = "opportunistic";
      fallbackDns = ["9.9.9.9#dns.quad9.net" "2620:fe::fe#dns.quad9.net"];
    };
  };

  systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart = ["" "${pkgs.networkmanager}/bin/nm-online -q"];
}
