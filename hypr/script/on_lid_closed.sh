#!/bin/bash

n_monitors=`hyprctl monitors | grep Monitor | wc -l`
echo N mon. $n_monitors

if [ $n_monitors -eq 1 ] 
then
    hyprlock;
    systemctl suspend;
else
    echo "More than 1 monitor";
    hyprctl keyword monitor "eDP-1, disable";
fi
