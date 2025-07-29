{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # Using the device for your laptop
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            # EFI System Partition
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            # A single LUKS partition taking up the rest of the disk
            luksroot = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                # By omitting any password or keyFile setting,
                # disko will prompt for a password interactively.
                settings = {
                  # Good practice for SSDs
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # Overwrite if it exists
                  subvolumes = {
                    # Subvolume for the root filesystem
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    # Subvolume for home directories
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    # Subvolume for the Nix store
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    # Subvolume to hold the swap file
                    "@swap" = {
                      mountpoint = "/.swapvol";
                      # This tells disko to create a swapfile here.
                      # The size should match your RAM for hibernation.
                      swap.swapfile.size = "32G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
