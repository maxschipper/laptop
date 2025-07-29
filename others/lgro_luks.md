---
id: lgro
created_at:
  date: 2025-07-28
  time: 11:02
tags:
  - note
---
# LUKS

also need to encryt swap
dont know how this works with btrfs and its subvolumes

## unlock with TPM2.0
TPM can be used to *unlock a LUKS-encrypted partition* **without** the need of entering the *password*.
Unlock is only possible on this specific device.
*Fallback password* can be allowed.


### package `tpm2-tools`
to test if TPM is working: `tpm2_getrandom 4`

`boot.initrd.systemd.enable = true;` # systemd im initrd – empfohlen!

`sudo systemd-cryptenroll --tpm2 /dev/nvme0n1p3` # p3 is already luks-encrypted partition here
- creates a TPM keyslot (without password)
- speichert TPM-PCRs mit denen gemessen wird, ob sich z. B. der Bootloader verändert hat
- you're still able to unlock with LUKS-password if TPM would fail

### nix config
```nix
boot.initrd.luks.devices."encroot" = {
  device = "/dev/disk/by-uuid/YOUR_UUID";
  tpm2 = true;
  fallbackPassword = true;
};
```
to get the UUID run `lsblk -o NAME,UUID`


## full btrfs setup?

Let's assume:
  - /dev/nvme0n1p1 = EFI
  - /dev/nvme0n1p2 = LUKS container for Btrfs
  - /dev/nvme0n1p3 = LUKS container for swap

Inside /dev/nvme0n1p2:
  - LUKS opens to /dev/mapper/encroot
  - encroot is a Btrfs filesystem
  - Btrfs subvolumes:
    - @root → /
    - @home → /home
    - @nix → /nix
    - etc.


*Format LUKS for root*
```sh
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup open /dev/nvme0n1p2 encroot
```

*Format Btrfs*
`mkfs.btrfs /dev/mapper/encroot`

*Mount and create subvolumes*
```sh
mount /dev/mapper/encroot /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@var
umount /mnt
```

*Then mount like this:*
```sh
mount -o subvol=@ /dev/mapper/encroot /mnt
mkdir -p /mnt/{home,nix,var}
mount -o subvol=@home /dev/mapper/encroot /mnt/home
mount -o subvol=@nix  /dev/mapper/encroot /mnt/nix
mount -o subvol=@var  /dev/mapper/encroot /mnt/var
```
*TPM enroll for root LUKS device*
`systemd-cryptenroll --tpm2 /dev/nvme0n1p2`


## NixOS sample config
```nix
boot.initrd.luks.devices."encroot" = {
  device = "/dev/disk/by-uuid/UUID-ROOT";  # Get via `lsblk -o UUID`
  tpm2 = true;
  fallbackPassword = true;
};

boot.initrd.luks.devices."cryptswap" = {
  device = "/dev/disk/by-uuid/UUID-SWAP";
  # You can skip TPM here if you want always-password or ephemeral
};
```

*Mounts for Btrfs subvolumes:*
```nix
fileSystems."/" = {
  device = "/dev/mapper/encroot";
  fsType = "btrfs";
  options = [ "subvol=@" ];
};

fileSystems."/home" = {
  device = "/dev/mapper/encroot";
  fsType = "btrfs";
  options = [ "subvol=@home" ];
};

fileSystems."/nix" = {
  device = "/dev/mapper/encroot";
  fsType = "btrfs";
  options = [ "subvol=@nix" ];
};

fileSystems."/var" = {
  device = "/dev/mapper/encroot";
  fsType = "btrfs";
  options = [ "subvol=@var" ];
};
```

*Swap setup:*
```nix
swapDevices = [{
  device = "/dev/mapper/cryptswap";
}];
```





