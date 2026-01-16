#!/bin/bash

if [ -f $HOME/.cache/waybar-disabled ] ;then
    rm $HOME/.cache/waybar-disabled
else
    touch $HOME/.cache/waybar-disabled
fi
$HOME/.config/waybar/launch.sh &