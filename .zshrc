# polarhive.ml/dots
# themeing
PS1="%~%{$fg[red]%}%{$reset_color%} "
autoload -U compinit
autoload -U colors && colors
setopt autocd
zstyle ':completion:*' menu select
zmodload zsh/complist

# history
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.local/share/zsh/history
setopt hist_ignore_dups
setopt hist_find_no_dups

# aliases
alias v="$EDITOR"
alias cat="bat"
alias ls="exa"
alias l="exa -l -a"
alias x="cd $SCRIPTS"
alias g="cd ~/Documents/Git/Codeberg"

# scripts
alias u="sh $SCRIPTS/link.sh"
alias s="sh $SCRIPTS/yt-dl/school.sh"
alias yt="sh $SCRIPTS/yt-dl/yt.sh"
alias m="sh $SCRIPTS/yt-dl/yt-mpv.sh"
alias c="sh $SCRIPTS/commit.sh"
alias k="sh $SCRIPTS/search.sh"
alias n="ncmpcpp"

function yta() {
    mpv --ytdl-format=bestaudio ytdl://ytsearch:"$*"
}

# plugins
source ~/Documents/Apps/local/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/Documents/Apps/local/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

