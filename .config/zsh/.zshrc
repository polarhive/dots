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
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[OA" history-beginning-search-backward-end
bindkey "^[OB" history-beginning-search-forward-end

# history
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.local/share/zsh/history

# source
source ~/.local/share/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.local/share/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/zsh/aliases
export PATH="$PATH:${$(find ~/.local/bin -type d -printf %p:)%%:}"
export SUDO_PROMPT='[sudo] %p 🗝  '
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
export GPG_TTY=$(tty)
