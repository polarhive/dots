{ config, pkgs, ... }:
{
  programs.yt-dlp = {
    enable = true;
    extraConfig = ''
      --add-metadata
      --embed-subs
      --restrict-filenames
      -f "best[width<=1920]"
    '';
  };
}
