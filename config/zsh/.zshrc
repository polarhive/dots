# =========================================================
# 00. XDG env.d loader (must be first)
# =========================================================
for f in "$HOME/.local/repos/github.com/polarhive/dots/config/env.d/"*.sh; do
  [ -r "$f" ] && . "$f"
done

# =========================================================
# 01. Plugin directory
# =========================================================
PLUGIN_DIR="$HOME/.local/share/zsh/plugins"

# =========================================================
# 02. Colors & Prompt
# =========================================================
autoload -Uz colors && colors
setopt prompt_subst
PS1="[%m:%F{red}%2~%f%{$reset_color%}]$%b "

# =========================================================
# 03. History
# =========================================================
export HISTFILE="$HOME/.local/share/zsh/history"
export HISTSIZE=10000000
export SAVEHIST=10000000
setopt append_history
setopt inc_append_history
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_find_no_dups

# =========================================================
# 04. Zsh behavior
# =========================================================
setopt auto_param_slash
setopt autocd
setopt extended_glob
setopt prompt_subst

# =========================================================
# 05. Load aliases
# =========================================================
[ -f "$ZDOTDIR/aliases" ] && source "$ZDOTDIR/aliases"

# =========================================================
# 06. Keybindings
# =========================================================
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[3~" delete-char
bindkey '^R' history-incremental-pattern-search-backward

# Optional history widgets
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

# =========================================================
# 07. Lightweight plugins
# =========================================================
# zoxide
#if [ -x "$PLUGIN_DIR/zoxide/zoxide" ]; then
  #eval "$($PLUGIN_DIR/zoxide/zoxide init zsh)"
#fi
eval "$(zoxide init zsh)"

# =========================================================
# 08. Heavy plugins
# =========================================================

# zsh-autosuggestions
if [ -f "$PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
  bindkey '^f' autosuggest-accept
fi

# zsh-syntax-highlighting
if [ -f "$PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# zsh-autocomplete
ZSH_AUTOCOMPLETE_INSTANT=true
ZSH_AUTOCOMPLETE_COMPLETE_INLINE=true
if [ -f "$PLUGIN_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]; then
  source "$PLUGIN_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
fi

# =========================================================
# 09. fzf setup
# =========================================================
for f in key-bindings.zsh completion.zsh; do
  [ -f "$PLUGIN_DIR/fzf/shell/$f" ] && source "$PLUGIN_DIR/fzf/shell/$f"
done

export FZF_DEFAULT_OPTS="
--height 40%
--layout=reverse
--border
--info=inline
--prompt='❯ '
"

# fzf history search widget (Ctrl+Space)
fzf-history-widget() {
  local selected
  selected="$(history 1 | fzf --tac --no-sort --height 40% --layout=reverse --border --prompt='History❯ ')"
  [[ -n "$selected" ]] && LBUFFER+="${selected##* }"
  zle redisplay
}
zle -N fzf-history-widget
bindkey '^ ' fzf-history-widget

# fzf fuzzy cd widget (Ctrl+D)
fzf-cd-widget() {
  local dir
  dir=$(find . -type d 2>/dev/null | fzf --height 40% --layout=reverse --border --prompt='Dir❯ ')
  [[ -n "$dir" ]] && cd "$dir"
  zle reset-prompt
}
zle -N fzf-cd-widget
bindkey '^D' fzf-cd-widget

# =========================================================
# 10. Completion system (must be last)
# =========================================================
export XDG_CACHE_HOME="$HOME/.cache"
mkdir -p "$XDG_CACHE_HOME/zsh"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/.zcompdump-$(hostname)-$EUID"

autoload -Uz compinit
compinit -C
zmodload zsh/complist
zstyle ':completion:*' menu yes select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# =========================================================
# 11. Disable .lesshst creation
# =========================================================
export LESSHISTFILE=/dev/null

# bun completions
[ -s "/Users/polarhive/.local/share/bun/_bun" ] && source "/Users/polarhive/.local/share/bun/_bun"
. "/Users/polarhive/.local/share/cargo/env"

