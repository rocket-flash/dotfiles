#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

setxkbmap -option "caps:escape"

export __GL_YIELD="USLEEP"

case $1 in
blackbox)
    exec blackbox
    ;;
xfce4|*)
    exec startxfce4
    ;;
esac
