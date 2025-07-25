{ config, pkgs, ... }:
{
  home.file."${config.xdg.configHome}/mpdscribble/mpdscribble.conf".text = ''
    [last.fm]
    url = https://post.audioscrobbler.com/
    username = polarhive
    password =
    journal = /Users/polarhive/.local/state/mpdscribble/lastfm.journal
  '';
}
