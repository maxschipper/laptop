{
  imports = [
    # Import the new, correct disko configuration.
    ./disko.nix
  ];

  # --- HIBERNATION CONFIGURATION ---
  # Disko now automatically finds the swap file and configures hibernation.
  # We just need to enable the service that makes it happen.
  services.btrfs.autoScrub.enable = true;

  # Bootloader configuration.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Configure LUKS for the root partition with TPM unlock.
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-label/luksroot";
    tpm2.enable = true;
    tpm2.fallbackToPassword = true;
    # This allows the initrd to mount the btrfs volume to find the swapfile.
    preLVM = true;
  };

  # Networking.
  networking.networkmanager.enable = true;

  # Time zone.
  time.timeZone = "Europe/Berlin";

  # User account.
  users.users.max = {
    isNormalUser = true;
    description = "Max";
    extraGroups = [ "wheel" ];
  };

  # Basic packages.
  environment.systemPackages = with pkgs; [
    vim
  ];

  # System state version.
  system.stateVersion = "24.05";
}
