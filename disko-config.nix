{ lib, ... }:
{
  # Disko configuration for a single NVMe SSD with LUKS-encrypted Btrfs.
  disko.devices = {
    disk = {
      # IMPORTANT: Verify this is the correct device for your SSD.
      # Use `lsblk` in the NixOS installer to confirm. It could be /dev/sda, /dev/vda, etc.
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            # EFI System Partition (ESP) for the bootloader.
            # 512MB is a standard size.
            ESP = {
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            # Unencrypted swap partition for hibernation.
            # Size should ideally match your RAM size (32GB).
            swap = {
              size = "32G";
              content = {
                type = "swap";
                # The resume offset is automatically configured by disko.
              };
            };

            # The main partition that will hold the LUKS encrypted container.
            # It takes up the rest of the available disk space.
            luks = {
              size = "100%";
              content = {
                type = "luks";
                # This name will be used to refer to the unlocked device, e.g., /dev/mapper/cryptroot
                name = "cryptroot";
                # Ask for a password during installation. This can be unlocked via TPM later.
                password = {
                  ask = true;
                  prompt = "LUKS root";
                };
                content = {
                  # Btrfs filesystem will be created inside the LUKS container.
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # Force creation, useful for re-running disko.
                  subvolumes = {
                    # The root subvolume, mounted at /
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    # Subvolume for user data.
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    # Subvolume for the Nix store.
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    # Subvolume for variable data like logs.
                    "@var" = {
                      mountpoint = "/var";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
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
