#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Multiple Monitor
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar -rq ws &
    MONITOR=$m polybar -rq tray &
    MONITOR=$m polybar -rq music &
    MONITOR=$m polybar -rq sysinfo &
  done
else
	polybar -rq ws &
	polybar -rq tray &
	polybar -rq music &
        polybar -rq sysinfo &        

	echo "Polybar launched..."
fi
