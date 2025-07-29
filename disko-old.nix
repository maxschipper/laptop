{
  # This configuration sets up an encrypted swap partition using a key file.
  # The key file itself will be stored on the encrypted root partition, so it is secure.

  # Tell disko to generate a secret key file for our swap encryption.
  disko.secrets.keyFiles."/etc/secrets/cryptswap.key" = { };

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # IMPORTANT: Verify this is the correct device for your SSD.
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            # EFI System Partition (ESP) for the bootloader.
            ESP = {
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            # This partition will hold the LUKS container for our swap.
            cryptswap = {
              size = "32G"; # Match RAM for hibernation.
              content = {
                type = "luks";
                name = "cryptswap";
                # Unlock this partition using the key file we defined above.
                # This avoids needing a second password on boot.
                keyFile = "/etc/secrets/cryptswap.key";
                content = {
                  type = "swap";
                  # This tells disko to automatically configure the system for hibernation.
                  resumeForHibernation = true;
                };
              };
            };

            # The main partition that will hold the LUKS encrypted container for the OS.
            luksroot = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                # This partition is unlocked with a password (and later TPM).
                password = {
                  ask = true;
                  prompt = "LUKS root";
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
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
