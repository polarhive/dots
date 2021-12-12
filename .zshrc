# ZSH configs
export ZSH="/home/polarhive/.oh-my-zsh"
ZSH_THEME="simple"
ENABLE_CORRECTION="true"
plugins=(zsh-syntax-highlighting zsh-autosuggestions git)

source $ZSH/oh-my-zsh.sh

### aliases
alias z="exit"
alias c="clear"
alias v="nvim"
alias ytmu="xdg-open https://music.youtube.com"
alias mu="playerctl play-pause"
alias pow="systemctl poweroff"
alias re="systemctl reboot"
alias logout="swaymsg exit"
alias b="cat /sys/class/power_supply/BAT0/capacity"
alias u="sh ~/Documents/Scripts/all.sh"
alias s="sh ~/Documents/Scripts/yt-dl/school.sh"
alias yt="sh ~/Documents/Scripts/yt-dl/yt.sh"
alias m="sh ~/Documents/Scripts/yt-dl/yt-mpv.sh"