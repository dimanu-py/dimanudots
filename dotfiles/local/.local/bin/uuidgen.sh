#!/bin/bash

uuid=$(uuidgen)

echo -n "$uuid" | wl-copy
# echo -n $uuid | xclip -selection clipboard
xdotool type "$uuid"
