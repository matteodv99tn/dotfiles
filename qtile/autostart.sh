#!/bin/sh


# cat /proc/acpi/button/lid/LID0/state | grep open -q
if grep -q "open" /proc/acpi/button/lid/LID0/state ; then
    echo "Open LID"
    xrandr --output eDP-1 --auto
    xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-1 --pos 1920x0 --rotate normal --output DP-1 --off --output DP-2 --off
else
    echo "Closed LID"
    xrandr --output eDP-1 --off
fi

# picom &
