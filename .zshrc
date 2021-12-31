# ZSH configs
export ZSH="/home/polarhive/.config/oh-my-zsh"
ZSH_THEME="simple"
plugins=(zsh-syntax-highlighting zsh-autosuggestions git)

source $ZSH/oh-my-zsh.sh

### aliases
alias z="exit"
alias c="clear"
alias b="acpi"
alias v="nvim"
alias code="codium"
alias wifi="nmcli connection show"
alias pi="ping gnu.org"
alias g="cd ~/Documents/Git/Codeberg"
alias poweroff="systemctl poweroff"
alias reboot="systemctl reboot"

#### scripts
alias u="sh ~/Documents/Scripts/all.sh"
alias s="sh ~/Documents/Scripts/yt-dl/school.sh"
alias yt="sh ~/Documents/Scripts/yt-dl/yt.sh"
alias blu="sh ~/Documents/Scripts/misc/bluetooth.sh"
alias m="sh ~/Documents/Scripts/yt-dl/yt-mpv.sh"
alias pgp="sh ~/Documents/Scripts/website/upload_keys.sh"
