# ZSH configs
export ZSH="/home/polarhive/.config/oh-my-zsh"
export EDITOR='nvim'
ZSH_THEME="simple"
plugins=(zsh-syntax-highlighting zsh-autosuggestions git)

source $ZSH/oh-my-zsh.sh

### aliases
alias z="exit"
alias c="clear"
alias b="acpi"
alias v="$EDITOR"
alias wifi="nmcli connection show"
alias pm="mpv ~/Music/*.mp3 --shuffle --no-audio-display"
alias pl="playerctl metadata | grep "title"; playerctl metadata | grep "artist";"
alias g="cd ~/Documents/Git/Codeberg"
alias poweroff="systemctl poweroff"
alias reboot="systemctl reboot"

#### scripts
alias u="sh ~/Documents/Scripts/all.sh"
alias s="sh ~/Documents/Scripts/yt-dl/school.sh"
alias yt="sh ~/Documents/Scripts/yt-dl/yt.sh"
alias m="sh ~/Documents/Scripts/yt-dl/yt-mpv.sh"
