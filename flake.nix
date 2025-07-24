{
  description = "mint: nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin }:
    let
      system = "aarch64-darwin";
      configuration = { pkgs, config, ... }: {
        nix = {
          settings = {
            experimental-features = "nix-command flakes";
          };
          optimise.automatic = true;
        };

        nixpkgs = {
          config.allowUnfree = true;
          hostPlatform = system;
        };

        environment.variables.ZDOTDIR = "/Users/polarhive/.config/zsh";
        security.pam.services.sudo_local.touchIdAuth = true;
        system.configurationRevision = self.rev or self.dirtyRev or null;
        system.primaryUser = "polarhive";
        system.stateVersion = 6;
        users.users.polarhive = {
          home = "/Users/polarhive";
          shell = pkgs.zsh;
        };

        environment.systemPackages = with pkgs; [
          bat
          eza
          kitty
          mkalias
          neovim
          obsidian
          yt-dlp
          tmux
          zoxide
        ];

        homebrew = {
          enable = true;
          onActivation = {
            upgrade = true;
            cleanup = "zap";
          };
          taps = [
            "FelixKratz/formulae"
            "nikitabobko/tap"
          ];
          casks = [
            "orbstack"
            "orion"
            "telegram-desktop"
            "visual-studio-code"
            "thunderbird"
            "aerospace"
          ];
          brews = [
            "batt"
            "sketchybar"
          ];
        };

        system.defaults = {
          dock.autohide = true;
          finder.FXPreferredViewStyle = "clmv";
          loginwindow.GuestEnabled = false;
          NSGlobalDomain = {
            AppleICUForce24HourTime = true;
            AppleInterfaceStyle = "Dark";
            KeyRepeat = 4;
          };
        };
      };
    in {
      darwinConfigurations."mint" = nix-darwin.lib.darwinSystem {
        system = system;
        modules = [ configuration ];
      };
    };
}
