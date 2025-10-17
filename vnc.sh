#!/bin/sh
Xvfb :99 -screen 0 1280x720x24 &
sleep 2
DISPLAY=:99 fluxbox &
x11vnc -display :99 -forever -nopw
