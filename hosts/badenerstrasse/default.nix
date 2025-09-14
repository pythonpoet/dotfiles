{
  fileSystems."/mnt/sda1" = {
      device = "/dev/disk/by-uuid/575abdac-97eb-4727-a4db-44c366b7da72";
      fsType = "ext4"; # or "vfat" / "ntfs" with appropriate options
      options = ["defaults" "nofail"];
    };

    fileSystems."/mnt/sba1" = {
      device = "/dev/disk/by-uuid/839e6d96-16ec-4529-9230-bfd74012a914";
      fsType = "ext4"; # or "vfat" / "ntfs" with appropriate options
      options = ["defaults" "nofail"];
    };

}