#!/bin/zsh
if [[ -z $DISPLAY && $TTY = /dev/tty1 ]]; then
  exec sway
  export $(dbus-launch)
fi
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
source $ZDOTDIR/.zshrc
