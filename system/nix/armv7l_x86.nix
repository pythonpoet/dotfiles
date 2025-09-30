# In your configuration.nix or other imported NixOS module
{ pkgs, ... }:

{
  # 1. Enable QEMU user-mode emulation for armv7l binaries.
  # This automatically installs the right QEMU static binaries and configures
  # the kernel's binfmt_misc to execute ARMv7 code transparently.
  boot.binfmt.emulatedSystems = [
    "armv7l-linux"
  ];

  # 2. Tell the Nix daemon that it can build for this new platform.
  # Nix will use the QEMU emulator configured above to run build steps.
  nix.settings.extra-platforms = [ "armv7l-linux" ];

  # Optional: Ensure QEMU is in the system path if you want to invoke it manually.
  # Note: This is not strictly necessary for the Nix build emulation to work.
  environment.systemPackages = [ pkgs.qemu ];
}