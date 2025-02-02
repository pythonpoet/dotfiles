{config}: let
  # Capture the current hostname
  hostName = config.networking.hostName;

  # Determine host-specific settings
  displayManager =
    if hostName == "alpakabook"
    then "gnome" # also hyprland
    else if hostName == "alpakapi"
    then "none"
    else "none";
in {
  displayManager = displayManager;

  # Optional: Export other host-specific settings or debugging info
  hostMessage = "For host: ${hostName}, display manager is set to: ${displayManager}";
}
