{ config, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  environment.systemPackages = import ./../../programs.nix { inherit pkgs; };

  # basics
  networking.hostName = "cider";
  time.timeZone = "Asia/Kolkata";
  system.stateVersion = "24.05";
  system.autoUpgrade.enable = false;

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # net
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;
  systemd.network.wait-online.enable = false;

  # (i18n)
  i18n.defaultLocale = "en_IN";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Settings
  users.users.polarhive = {
    isNormalUser = true;
    description = "Nathan";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  users.defaultUserShell = pkgs.zsh;
  programs.sway = { enable = true; wrapperFeatures.gtk = true; };
  programs.firefox.enable = true;
  programs.zsh.enable = true;
  environment.variables.ZDOTDIR = "/home/polarhive/.config/zsh";

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [];
    fontconfig.defaultFonts = {
      serif = [ "Product Sans" ];
      sansSerif = [ "Product Sans" ];
      monospace = [ "Input Mono" ];
    };
  };

  # Audio and Sound
  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa = { enable = true; support32Bit = true; };
    pulse.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;                       # Enable GPG agent
    enableSSHSupport = true;             # Enable SSH support for GPG agent
  };

  # Nix Configuration
  nixpkgs.config.allowUnfree = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
