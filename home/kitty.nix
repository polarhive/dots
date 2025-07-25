{ config, pkgs, ... }:
{
  programs.kitty = {
    enable = true;
  };
  home.file."${config.xdg.configHome}/kitty/kitty.conf".text = ''
# vim:fileencoding=utf-8:foldmethod=marker

# BEGIN_KITTY_FONTS
font_family      family="Input Mono"
bold_font        auto
italic_font      auto
bold_italic_font auto
# END_KITTY_FONTS

font_size 20
window_padding_width 8
tab_bar_style powerline
enable_audio_bell no
  '';
}
