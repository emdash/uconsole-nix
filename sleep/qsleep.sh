#!/usr/bin/env bash

# dependencies needed:
#
# libinput-tools
# cpulimit
# sysstat
# wlr-randr
# procps

set -euo pipefail

# Don't put these processes to sleep, or we may never wake up
EXCLUDED_PROCS="${0}|systemd|pipewire|wireplumber|wayfire|labwc|sway|ssh|tmux|screen|top"

function governor {
  if ! test -v 1
  then
    cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
  else
    case "$1" in
      sleep) bin/set_governor 0;;
      wake)  bin/set_governor 1;;
    esac
  fi
}

function display {
  case "$1" in
    off) wlr-randr --output DSI-1 --off;;
    on)  wlr-randr --output DSI-1 --on --transform 270;;
  esac
}

function limit_procs {
  while true;
  do 
  for pid in $(pidstat 1 1 | grep "^Average:" | awk "BEGIN {FS=\"[[:space:]]+\"} \$8 > 5 {print \$3}");
  do
    sleep 60
    cpulimit -zo -l 1 --pid="${pid}"
  done; 
  done > /dev/null 2>&1
}

function procs {
  case "$1" in
    sleep)
      ps -U $USER | tail -n +2 | egrep -v "${EXCLUDED_PROCS}" | while read pid
      do
	echo "${pid}"
        # kill -STOP "${pid}"
      done
      # nohup "$0" limit_procs
      # disown
      ;;
    wake)
      kill -CONT -1
      #killall pidstat
      #killall cpulimit
      #pkill -f qsleep_bg
      #killall qsleep.sh
      ;;
  esac
}

function toggle {
  if test "$(cat /sys/class/drm/card1-DSI-1/enabled)" = "enabled"
  then
    # Display is on, put device into powersave mode
    display off
    nohup swaylock -i "${HOME}/.config/sway/background" > /dev/null &
    disown
    governor sleep
    # procs sleep
  else
    governor wake
    # procs wake
    display on
  fi
}

function watch {
  declare -a event
  libinput debug-events --device /dev/input/event0 | while read -a event
  do
    case "${event[1]} ${event[3]} ${event[5]}" in
			"KEYBOARD_KEY KEY_POWER released")
			   toggle
			   ;;
    esac
  done
}

if ! test -v 1
then
  echo "Toggling Sleep State"
  toggle
else
  "$@"
fi
