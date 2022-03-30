## themeing
autoload -U compinit
autoload -U colors && colors
setopt autocd
zstyle ':completion:*' menu select
zmodload zsh/complist
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

# env variables
export MOZ_ENABLE_WAYLAND=1
export MOZ_DBUS_REMOTE=1
export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="firefox"
export READER="zathura"
export VIDEO="mpv"
export XDG_SESSION_TYPE="wayland"
export XDG_CURRENT_DESKTOP="sway"
export LESSHISTFILE=-

# History
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.local/share/zsh/history
setopt hist_ignore_dups
setopt hist_find_no_dups

### aliases
alias wifi="nmcli connection show"
alias b="acpi"
alias v="$EDITOR"
alias cat="bat"
alias ls="exa"
alias l="exa -l -a"
alias du="du -h"
alias g="cd ~/Documents/Git/Codeberg"
alias x="cd ~/Documents/Scripts/"

#### scripts
alias u="sh ~/Documents/Scripts/misc/link.sh"
alias s="sh ~/Documents/Scripts/yt-dl/school.sh"
alias yt="sh ~/Documents/Scripts/yt-dl/yt.sh"
alias m="sh ~/Documents/Scripts/yt-dl/yt-mpv.sh"
alias c="sh ~/Documents/Scripts/misc/commit.sh"

# plugins
source ~/Documents/Apps/local/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/Documents/Apps/local/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

