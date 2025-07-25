{ config, pkgs, ... }:
{
  services.mpd = {
    enable = true;
    musicDirectory = "~/Music";
    dataDir = "/Users/polarhive/.local/share/mpd";
    extraConfig = ''
      auto_update "no"
      restore_paused "yes"
      follow_outside_symlinks "yes"
      log_file "~/.local/share/mpd/log"
      state_file "~/.local/share/mpd/state"
      db_file "~/.local/share/mpd/database"
      playlist_directory "~/.local/share/mpd/playlists"
      audio_output {
        type  "osx"
        name  "CoreAudio"
      }
    '';
  };
}
