---
id: tmxn
created_at:
  date: 2025-07-26
  time: 16:26
tags:
  - note
---
# systemd-boot

## enable systemd-boot
```nix
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
```


## dual boot windows
https://wiki.nixos.org/wiki/Dual_Booting_NixOS_and_Windows
`sudo bootctl install` to reinstall systemd-boot? to detect windows install for dual boot
```nix
boot.loader.entries = {
  "windows.conf" = ''
    title   Windows 11
    efi     /EFI/Microsoft/Boot/bootmgfw.efi
  '';
};
```

## make it fast
> disable boot selector; still available when holding down a key like space, arr-down, esc?
```nix
{
  boot.loader.timeout = 0;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;         # Don't always show menu
  boot.loader.timeout = 3;                         # Short timeout for keypress override

  boot.loader.efi.canTouchEfiVariables = true;
}
```
`boot.loader.systemd-boot.configurationLimit = 10;# limit to 10 boot entries` 
> Setting this to a lower amount than the default may help reduce the occasions where too many different kernels and initrds are added to the /boot partition or ESP.





