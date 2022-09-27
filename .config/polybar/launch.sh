#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Multiple Monitor
if type "polybar"; then
  for m in $(polybar --list-monitors | cut -d":" -f1); do
    MONITOR=$m polybar -rq ws &
    MONITOR=$m polybar -rq tray &
    MONITOR=$m polybar -rq sysinfo &
    MONITOR=$m polybar -rq window & 
 done
else
	polybar -rq ws &
	polybar -rq tray &
        polybar -rq sysinfo &        
	polybar -rq window &

	echo "Polybar launched..."
fi
