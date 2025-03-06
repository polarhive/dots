# tweaks
PS1="[%m:%F{red}%2~%f%{$reset_color%}]$%b "
autoload -U compinit && compinit
autoload -U colors && colors

# Keybindings
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[3~" delete-char
bindkey '^R' history-incremental-pattern-search-backward

# Zsh options
setopt append_history
setopt auto_param_slash
setopt autocd
setopt extended_glob
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt inc_append_history
setopt prompt_subst
setopt share_history

# Zsh widgets
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

# Load zsh/complist module
zmodload zsh/complist

# History settings
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.local/share/zsh/history

# Highlighting styles
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#ccb521'  # Style for double-hyphen options
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#22b587' # Style for single-hyphen options

# Source additional scripts
source ~/.config/zsh/aliases
source ~/.local/share/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.local/share/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.local/share/zsh/zoxide/z.zsh
