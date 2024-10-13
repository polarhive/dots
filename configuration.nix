{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  networking.hostName = "cider";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.polarhive = {
    isNormalUser = true;
    description = "Nathan";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  programs.firefox.enable = true;
  programs.zsh = {
    enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
  services.openssh.enable = false;
  services.tailscale.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    inter
  ];

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.acpi
    pkgs.bat
    pkgs.wl-clipboard
    pkgs.beeper
    pkgs.eza
    pkgs.foot
    pkgs.fzf
    pkgs.git
    pkgs.htop
    pkgs.imv
    pkgs.inter
    pkgs.mako
    pkgs.mpv
    pkgs.neovim
    pkgs.delta
    pkgs.obsidian
    pkgs.pfetch
    pkgs.pnpm
    pkgs.sway
    pkgs.swaybg
    pkgs.swaylock
    pkgs.telegram-desktop
    pkgs.thunderbird
    pkgs.tmux
    pkgs.vscode
    pkgs.wofi
    pkgs.xfce.thunar
    pkgs.yt-dlp
    pkgs.zoxide
    pkgs.zsh
  ];

   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

  system.stateVersion = "24.05";
  system.autoUpgrade = {
     enable = true;
  };
  nix.gc = {
                automatic = true;
                dates = "weekly";
                options = "--delete-older-than 7d";
           };
}

