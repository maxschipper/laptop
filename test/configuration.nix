{
  imports = [
    ./disko-config.nix
  ];

  # Enable the XFCE Desktop Environment.
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment the following line:
    #jack.enable = true;

    # use the example session manager (no others are packaged yet)
    #media-session.enable = true;
  };

  # Enable networking.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "us";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled by default).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with `passwd`.
  users.users.max = {
    isNormalUser = true;
    description = "Max Mustermann";
    extraGroups = [ "wheel" ]; # Enable sudo
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages you want to install.
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add some text editor!
    wget
    git
    firefox
    htop
    neofetch
    # ... and so on
  ];

  # Some programs need SUID wrappers, otherwise they will not work.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable.

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
