{ config, pkgs, ... }:
{
  # Shared options, e.g. environment variables, fonts, etc.
  home.sessionVariables = {
    EDITOR = "nvim";
    PAGER = "bat";
    GNUPGHOME = "~/.local/share/gnupg";
    LESSHISTFILE = "-";
    PATH = "$PATH:$(find ~/.local/bin -type d | tr '\n' ':' | sed 's/:$//')";
    PYTHON_HISTORY = "~/.local/share/python/history";
    SSH_AUTH_SOCK = "/run/user/1000/gcr/ssh";
    SUDO_PROMPT = "[sudo] %p 🗝  ";
    npm_config_cache = "~/.cache/npm";
    npm_config_userconfig = "~/.config/npm/config";
  };
}