{
  imports = [
    # Import the disk configuration with encrypted swap.
    ./disko-config-encrypted-swap.nix
  ];

  # Bootloader configuration.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Configure LUKS for the root partition with TPM unlock.
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-label/luksroot"; # Label from disko
    tpm2.enable = true;
    tpm2.fallbackToPassword = true;
  };

  # Configure LUKS for the swap partition.
  # It will be unlocked using the key file we created in the disko config.
  boot.initrd.luks.devices."cryptswap" = {
    device = "/dev/disk/by-label/cryptswap"; # Label from disko
    keyFile = "/etc/secrets/cryptswap.key";
  };

  # Enable networking.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Define a user account.
  users.users.max = {
    isNormalUser = true;
    description = "Max";
    extraGroups = [ "wheel" ];
  };

  # Install a basic text editor.
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Set the system state version.
  system.stateVersion = "24.05";
}
