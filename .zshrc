## themeing
autoload -U compinit
autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
setopt autocd

# env variables
export MOZ_ENABLE_WAYLAND=1
export MOZ_DBUS_REMOTE=1
export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="firefox"
export READER="zathura"
export XDG_SESSION_TYPE="wayland"
export XDG_CURRENT_DESKTOP="sway"

### aliases
alias wifi="nmcli connection show"
alias b="acpi"
alias v="$EDITOR"
alias cat="bat"
alias ls="exa"
alias l="exa -l -a"
alias du="du -h"
alias g="cd ~/Documents/Git/Codeberg"

#### scripts
alias u="sh ~/Documents/Scripts/misc/link.sh"
alias s="sh ~/Documents/Scripts/yt-dl/school.sh"
alias yt="sh ~/Documents/Scripts/yt-dl/yt.sh"
alias m="sh ~/Documents/Scripts/yt-dl/yt-mpv.sh"
alias c="sh ~/Documents/Scripts/misc/commit.sh"

# plugins
source ~/Documents/Apps/local/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

