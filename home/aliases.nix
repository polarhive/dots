{ config, pkgs, ... }:
{
  programs.zsh = {
    shellAliases = {
      acpi = "batt status";
      age = "eval \"$(ssh-agent -s)\" && ssh-add --apple-use-keychain ~/.ssh/id_ed25519";
      b = "~/.local/bin";
      bc = "python -q";
      cat = "bat";
      cd = "z";
      fm = "~/.local/repos/jukebox/.venv/bin/jukebox-fm";
      g = "git";
      gr = "~/.local/repos";
      gs = "g status";
      l = "eza";
      la = "eza --group-directories-first -a -F=always";
      ll = "eza --group-directories-first -a -F=always --long";
      ls = "eza --group-directories-first -F=always";
      lt = "eza --tree";
      man = "batman";
      n = "ncmpcpp -q";
      newsboat = "newsboat -q";
      ssh = "age; kitten ssh";
      tmux = "tmux a || tmux";
      v = "$EDITOR";
      wf = "nmcli radio wifi off";
      wo = "nmcli radio wifi on";
      k = "echo ji";
    };
  };
}
