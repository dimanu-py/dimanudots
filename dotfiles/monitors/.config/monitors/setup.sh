#!/bin/bash

default_internal_monitor="eDP-1"
default_display_name="DVI"

display_name=${1:-$default_display_name}
internal_monitor=${2:-$default_internal_monitor}

mapfile -t external_monitors < <(xrandr | grep ' connected' | grep "$display_name" | awk '{print $1}')

if [ ${#external_monitors[@]} -eq 0 ]; then
	echo "No monitors found matching: $display_name"
	exit 1
fi

for i in "${!external_monitors[@]}"; do
	index=$((i + 1))
	declare "monitor_$index=${external_monitors[i]}"
done

xrandr --output "$monitor_1" --primary --mode 1920x1080 --pos 1920x0 --rotate normal
echo "Set $monitor_1 as mirror of internal monitor"

xrandr --output "$monitor_2" --mode 1920x1080 --pos 0x0
echo "Set $monitor_2 as monitor on the right of $monitor_1 main monitor"