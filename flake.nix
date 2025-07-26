{
  description = "mint: nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
    in {
      darwinConfigurations."mint" = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ({ config, pkgs, ... }: {
            nix = {
              settings.experimental-features = "nix-command flakes";
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
          bat-extras.batdiff
          bat-extras.batgrep
          bat-extras.batman
          bat-extras.batpipe
          btop
          delta
          eza
          fastfetch
          ffmpeg
          go
          mpc
          neovim
          obsidian
          openssl
          telegram-desktop
          thunderbird
          vscode
          zoxide
          ];

            homebrew = {
              enable = true;
              onActivation = {
                upgrade = true;
                cleanup = "zap";
              };
              brews = [
                "mpdscribble"
                "sketchybar"
              ];
              taps = [
                "FelixKratz/formulae"
                "nikitabobko/tap"
              ];
          casks = [
            "aerospace"
            "alt-tab"
            "beeper"
            "orbstack"
            "orion"
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
            
            programs.ssh.knownHosts = {};
            environment.extraInit = ''
              if [ -z "$SSH_AUTH_SOCK" ]; then
                eval "$(ssh-agent -s)" > /dev/null
              fi
              
              ssh-add -l | grep -q "$(ssh-keygen -lf ~/.ssh/id_ed25519 | awk '{print $2}')" || \
                ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2>/dev/null
            '';
          })

          home-manager.darwinModules.home-manager

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.polarhive = {
              imports = [
                ./home/common.nix
                ./home/tmux.nix
                ./home/mpd.nix
                ./home/ssh.nix
                ./home/ncmpcpp.nix
                ./home/mpv.nix
                ./home/bat.nix
                ./home/zsh.nix
                ./home/aliases.nix
                ./home/yt-dlp.nix
                ./home/newsboat.nix
                ./home/kitty.nix
              ];
              home.stateVersion = "23.11";
            };
          }
        ];
      };
    };
}
