{
  services = {
    
    logind.settings.Login = {
      # Power button handling
      HandlePowerKey = "suspend";
      HandlePowerKeyLongPress = "poweroff";
      
      # Lid switch (for Surface devices)
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
      
      # Other power keys
      HandleSuspendKey = "suspend";
      HandleHibernateKey = "hibernate";
      
      # Session management (keep default NixOS behavior)
      KillUserProcesses = false;
      
      # Power management timing
      IdleAction = "suspend";
      IdleActionSec = "30min";
      HoldoffTimeoutSec = "30s";
      
      # Additional Surface-specific settings
      PowerKeyIgnoreInhibited = "no";
      SuspendKeyIgnoreInhibited = "no";
    };
    power-profiles-daemon.enable = true;
    # battery info
    upower.enable = true;
    
  };
}
