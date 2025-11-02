{lib, ...}: {
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
    media-session.enable = false; # disable old session manager

    wireplumber.extraConfig."wireplumber.profiles".main."monitor.libcamera" = "enabled";
  };

  hardware.pulseaudio.enable = lib.mkForce false;
  hardware.camera.enable = true;
  services.wireplumber.enable = true;


}
