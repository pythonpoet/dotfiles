let
  alpakapro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAOr7hdJO0P2TBs5GH+XmOi7XoBT6LiAS7Ym6IEgM2H0 david@alpakapro";
  bernina = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOc1VdjIPZ92jdNqIkFkn1/C8viTw/7Fqr45bYw0RUA david@bernina";
in {
  "spotify.age".publicKeys = [mihai io];
  "borg.age". publicKeys = [bernina]
}
