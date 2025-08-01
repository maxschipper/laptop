{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # Using the device for your laptop
        device = "/dev/XXX";
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
                mountOptions = [ "umask=0077" ];
              };
            };
            # A single LUKS partition taking up the rest of the disk
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                # By omitting any password or keyFile setting,
                # disko will prompt for a password interactively.
                passwordFile = "/tmp/secret.key";
                settings = {
                  # Good practice for SSDs
                  allowDiscards = true;
                };
                additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                    "-L"
                    "nixos"
                  ]; # Overwrite if it exists + label nixos
                  subvolumes = {
                    # Subvolume for the root filesystem
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    # Subvolume for home directories
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    # Subvolume for the Nix store
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    # Subvolume for the logs
                    "@logs" = {
                      mountpoint = "/var/logs";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    # Subvolume to hold the swap file
                    "@swap" = {
                      mountpoint = "/.swapvol";
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
