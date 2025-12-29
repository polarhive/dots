#!/usr/bin/env bash
set -e

echo "=== Updating system ==="
sudo apt update

echo "=== Installing packages ==="
sudo apt install -y \
  curl git zsh neovim eza fzf \
  zsh-autosuggestions zsh-syntax-highlighting \
  ca-certificates gnupg lsb-release

echo "=== Installing zoxide ==="
if ! command -v zoxide >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

echo "=== Installing Docker ==="
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
fi

echo "=== Installing Tailscale ==="
if ! command -v tailscale >/dev/null 2>&1; then
  curl -fsSL https://tailscale.com/install.sh | sh
  sudo systemctl enable --now tailscaled
fi

echo "=== Installing zsh-autocomplete ==="
mkdir -p ~/.local/share/zsh
if [ ! -d ~/.local/share/zsh/zsh-autocomplete ]; then
  git clone https://github.com/marlonrichert/zsh-autocomplete \
    ~/.local/share/zsh/zsh-autocomplete
fi

echo "=== Writing ~/.aliases ==="
cat > "$HOME/.aliases" <<'EOF'
alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --group-directories-first'
alias la='eza -a --icons'
alias l='eza --icons'

alias v='nvim'

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
EOF

echo "=== Writing ~/.zshrc ==="
cat > "$HOME/.zshrc" <<'EOF'
##### Prompt #####
autoload -Uz colors && colors
setopt prompt_subst
PS1="[%m:%F{red}%2~%f%{$reset_color%}]$%b "

##### History #####
HISTFILE=~/.local/share/zsh/history
HISTSIZE=10000000
SAVEHIST=10000000

setopt append_history
setopt inc_append_history
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_find_no_dups

##### Zsh behavior #####
setopt autocd
setopt auto_param_slash
setopt extended_glob
setopt interactivecomments

##### Completion system #####
autoload -Uz compinit
compinit
zmodload zsh/complist
zstyle ':completion:*' menu yes select
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

##### Keybindings #####
bindkey '^[[C' autosuggest-accept        # →
bindkey '^f' autosuggest-accept           # Ctrl+f

##### Load aliases #####
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"

##### zoxide #####
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

##### fzf (dropdown style) #####
export FZF_DEFAULT_OPTS="
--height 40%
--layout=reverse
--border
--info=inline
--prompt='❯ '
"
if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
  source /usr/share/doc/fzf/examples/completion.zsh
fi

fzf-dropdown-widget() {
  local selected
  selected=$(fzf)
  [[ -n "$selected" ]] && LBUFFER+="$selected"
  zle redisplay
}
zle -N fzf-dropdown-widget
bindkey '^ ' fzf-dropdown-widget    # Ctrl+Space

##### Autosuggestions #####
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

##### Syntax highlighting #####
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

##### zsh-autocomplete (Fish-like suggestions + menu) #####
if [ -f ~/.local/share/zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]; then
  source ~/.local/share/zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh
fi
EOF

echo "=== Setting zsh as default shell ==="
if [ "$SHELL" != "$(command -v zsh)" ]; then
  sudo chsh -s "$(command -v zsh)"
fi

echo "=== DONE ==="
echo "➡ Log out & back in (Docker group + shell)"
echo "➡ Or run: exec zsh"
echo "➡ Then: tailscale up"

