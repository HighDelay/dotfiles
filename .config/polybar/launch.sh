#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Multiple Monitor
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar -rq music & polybar -rq tray & polybar -rq ws &
  done
else
	polybar -rq music &
	polybar -rq tray &
	polybar -rq ws &

	echo "Polybar launched..."
fi
