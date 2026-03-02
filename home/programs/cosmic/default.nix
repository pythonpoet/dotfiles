{pkgs, ...}:{
  services.displayManager = {
     # Enable the COSMIC desktop environment
    cosmic.enable = true;
    # Enable the COSMIC login manager
    cosmic-greeter.enable = true;
    autoLogin = {
        enable = true;
        user = "david";
      };
  };
  environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
}