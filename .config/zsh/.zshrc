# tweaks
PS1="[%m:%F{red}%~%f%{$reset_color%}]$%b "
autoload -U colors && colors
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
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
zmodload zsh/complist
zstyle ':completion:*' menu select

# history
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.local/share/zsh/history

# source
source ~/.config/zsh/aliases
source ~/.local/share/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.local/share/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# pnpm
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
