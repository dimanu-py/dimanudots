#!/bin/zsh

yay -S -y evdi displaylink
echo "Installed evdi and displaylink successfully"

systemctl enable displaylink.service
echo "Displaylink enable"

file_path="/etc/X11/xorg.conf.d/20-evdi.conf"

if [ ! -d "$(dirname "$file_path")"  ]; then
	sudo mkdir -p "$(dirname "$file_path")"
fi

sudo tee "$file_path" > /dev/null << EOF
Section "OutputClass"
	Identifier "DisplayLink"
	MatchDriver "evdi"
	Driver "modesetting"
	Option "AccelMethod" "none"
EndSection
EOF
echo "Configuration written to $file_path"