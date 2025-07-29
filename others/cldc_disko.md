---
id: cldc
created_at:
  date: 2025-07-28
  time: 11:36
tags:
  - note
---
# disko


## disko-config.nix
```nix
{
  disko.devices.ssd = {
    type = "disk";
    device = "/dev/nvme0n1";  # adjust to your actual device, e.g. sda, nvme0n1

    content = {
      type = "gpt";

      partitions = {
        # EFI partition, mounted at /boot, FAT32, 512MB
        esp = {
          type = "EF00";
          size = "512M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        # Swap partition (unencrypted), 32GB for hibernation
        swap = {
          type = "8200"; # linux swap partition type
          size = "32G";
          content = {
            type = "swap";
          };
        };

        # LUKS encrypted partition for root filesystem
        luksroot = {
          size = "100%";  # rest of disk
          content = {
            type = "luks";
            name = "cryptroot";

            content = {
              type = "btrfs";

              subvolumes = {
                # Root subvolume mounted at /
                "@".mountpoint = "/";
                # Home subvolume mounted at /home
                "@home".mountpoint = "/home";
                # Nix store mounted at /nix
                "@nix".mountpoint = "/nix";
                # /var mounted separately for logs etc
                "@var".mountpoint = "/var";
              };
            };
          };
        };
      };
    };
  };
}
```
## Important parts of configuration.nix
```nix
{ config, pkgs, ... }:

{
  # Use the EFI partition mounted at /boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Tell NixOS to use the encrypted luks partition and TPM2 to auto-unlock it
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-partlabel/luksroot";  # matches the partition label in Disko config
    tpm2 = true;            # enable TPM2 integration for auto-unlock
    fallbackPassword = true; # fallback password prompt in case TPM fails
    # Needed for hibernation to find the resume device
    resumeDevice = true;
  };

  # Setup swap on the unencrypted swap partition
  swapDevices = [
    {
      device = "/dev/disk/by-partlabel/swap";
    }
  ];

  # Kernel param for resume (helpful for hibernation)
  boot.kernelParams = [
    "resume=/dev/disk/by-partlabel/swap"
  ];

  # Mount options for Btrfs subvolumes
  fileSystems."/" = {
    device = "LABEL=luksroot";  # or the btrfs partition device inside luks (you can use /dev/mapper/cryptroot)
    fsType = "btrfs";
    mountOptions = [ "subvol=@" "compress=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "LABEL=luksroot";
    fsType = "btrfs";
    mountOptions = [ "subvol=@home" "compress=zstd" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "LABEL=luksroot";
    fsType = "btrfs";
    mountOptions = [ "subvol=@nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/var" = {
    device = "LABEL=luksroot";
    fsType = "btrfs";
    mountOptions = [ "subvol=@var" "compress=zstd" "noatime" ];
  };

  # Enable systemd-boot on EFI partition
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable TPM2 support system-wide
  services.tpm2.enable = true;
}
```
