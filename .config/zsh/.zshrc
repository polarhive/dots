# polarhive.ml/dots
# themeing
PS1="%~%{$fg[red]%}%{$reset_color%} "

# tweaks
autoload -U colors && colors
autoload -U compinit
bindkey "^[3;5~" delete-char
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[3~" delete-char
bindkey '^R' history-incremental-pattern-search-backward
setopt append_history
setopt auto_param_slash
setopt autocd
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt inc_append_history
setopt prompt_subst
setopt share_history
zmodload zsh/complist
zstyle ':completion:*' menu select

# history
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.local/share/zsh/history

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
source ~/.local/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.local/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.local/zsh/zsh-cd/zsh-cd.zsh
source ~/.local/share/cargo/env

