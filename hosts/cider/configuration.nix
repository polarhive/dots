{ config, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  environment.systemPackages = import /home/polarhive/.local/repos/dots/programs.nix { inherit pkgs; };
  nix.settings = {
    experimental-features = "nix-command flakes";
  };
  
  # basics
  networking.hostName = "cider";
  time.timeZone = "Asia/Kolkata";
  system.stateVersion = "25.05";
  system.autoUpgrade.enable = false;

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # net
  networking.networkmanager.enable = true;
  systemd.network.wait-online.enable = false;

  # services
  services = {
    displayManager.ly.enable = true;
    gnome.gnome-keyring.enable = true;

    gvfs.enable = true;
    tailscale.enable = true;
    udisks2.enable = true;
    pipewire = {
      enable = true;
      wireplumber.enable = true;
      alsa = { enable = true; support32Bit = true; };
      pulse.enable = true;
    };
  };

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
  programs.zsh.enable = true;
  environment.variables.ZDOTDIR = "/home/polarhive/.config/zsh";

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      input-fonts
    ];
    fontconfig.defaultFonts = {
      serif = [ "Product Sans" ];
      sansSerif = [ "Product Sans" ];
      monospace = [ "InputMono Nerd Font" ];
    };
  };

  # Audio and Sound
  hardware.bluetooth.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.input-fonts.acceptLicense = true;
}

