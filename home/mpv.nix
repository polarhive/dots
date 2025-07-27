{ config, pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    config = {
      af = "scaletempo2";
      audio-file-auto = "fuzzy";
      autofit-larger = "100%x100%";
      cache = "no";
      hwdec="auto";
      msg-level = "ffmpeg=fatal";
      osc = true;
      save-position-on-quit = true;
      screenshot-directory = "~/Pictures/Screenshots";
      screenshot-template = "%F - [%P]v%#01n";
      slang = "en";
      sub-auto = "fuzzy";
      sub-blur = 5;
      sub-bold = true;
      sub-font = "Inter";
      sub-font-size = 25;
      sub-pos = 98;
      sub-scale = 0.7;
      sub-visibility = true;
      term-playing-msg = "Title: \${media-title}";
      ytdl-format = "best[height<=720]";
      ytdl-raw-options = "ignore-config=,sub-lang=en,write-auto-sub=";
    };
  };
}
