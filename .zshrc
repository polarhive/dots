# ZSH configs
export ZSH="/home/polarhive/.config/oh-my-zsh"
export EDITOR='nvim'
ZSH_THEME="simple"
plugins=(zsh-syntax-highlighting zsh-autosuggestions git)

source $ZSH/oh-my-zsh.sh

### aliases
alias b="acpi"
alias cat="bat"
alias ls="exa"
alias du="du -h"
alias v="$EDITOR"
alias wifi="nmcli connection show"
alias g="cd ~/Documents/Git/Codeberg"
alias poweroff="sudo poweroff"
alias reboot="sudo reboot"

#### scripts
alias u="sh ~/Documents/Scripts/misc/link.sh"
alias s="sh ~/Documents/Scripts/yt-dl/school.sh"
alias yt="sh ~/Documents/Scripts/yt-dl/yt.sh"
alias m="sh ~/Documents/Scripts/yt-dl/yt-mpv.sh"
alias c="sh ~/Documents/Scripts/misc/commit.sh"
