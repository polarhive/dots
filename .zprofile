#!/bin/zsh
if [[ -z $DISPLAY && $TTY = /dev/tty1 ]]; then
  exec sway
  export $(dbus-launch)
fi
