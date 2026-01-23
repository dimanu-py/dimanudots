# Monitor Setup

[![Bash Script](https://img.shields.io/badge/Bash-Script-green?style=for-the-badge&logo=gnu-bash&logoColor=white&labelColor=101010)]()

## Description

This repo contains two bash scripts needed to be able to work with two external monitors using a docking station that works with DisplayLink software.

> [!IMPORTANT]
> These scripts are meant to be executed in an ArchLinux distro

1. [Install drivers](#drivers)
2. [Monitor configuration](#monitors)
3. [Execute configuration automatically](#configuration)
    1. [Execute on login](#login)
    2. [Execute on boot](#boot)

<a name=drivers></a>
## Install drivers

The *drivers_installation.sh* script will install displaylink driver and evid for the kernel module.

Once these packages are installed it will create a *20-evdi.conf* file inside */etc/X11/Xorg.conf.d* directory. 
Then, the following content will be loaded inside this file:

```text
Section "OutputClass"
	Identifier "DisplayLink"
	MatchDriver "evdi"
	Driver "modesetting"
	Option "AccelMethod" "none"
EndSection
```

> [!NOTE]
> It may be necessary to restart the system after the installation.

<a name=monitors></a>
## Monitor configuration and setup

Once the first script has finished installing everything run:

```bash
xrandr --listproviders
```

You should see a list of provider similar to this one (the number of providers may vary depending on how monitors do you have and if there is a dedicated GPU or not):

```text
Providers: number : 4
Provider 0: id: 0x46 cap: 0xf, Source Output, Sink Output, Source Offload, Sink Offload crtcs: 4 outputs: 4 associated providers: 2 name:modesetting
Provider 1: id: 0x2d9 cap: 0x2, Sink Output crtcs: 1 outputs: 1 associated providers: 1 name:modesetting
Provider 2: id: 0x2a7 cap: 0x2, Sink Output crtcs: 1 outputs: 1 associated providers: 1 name:modesetting
Provider 3: id: 0x286 cap: 0x0 crtcs: 0 outputs: 0 associated providers: 0 name:NVIDIA-G0
```

Set the providers 1 and 2 (both external monitors) to the first provider of the list

```bash
xrandr --setprovideroutputsource 1 0
xrandr --setprovideroutputsource 2 0
```

Then run the *setup.sh* script to set the external monitors.

This script admits two arguments:
1. The display name. By default, it gets _DVI_ but a different name can be passed, such as _HDMI_.
2. The name of the internal monitor. My laptop by default is named _eDP1_ but a different name can be passed.

The script will capture all the connected external monitors, set the first as the primary and the rest as extensions of the primary.

> [!NOTE]
> If the monitors work with a resolution different of 1920x1080, the change must be done inside the script.

<a name=configuration></a>
## Automatic configuration

<a name=login></a>
### Execute on login

To run the *setup.sh* script automatically when logging:

1. Open _.xprofile_ file
2. Add the following command
    ```bash
   sh <path_to_script> 
   ```
3. Save the file

<a name=boot></a>
### Execute on boot

To run the *setup.sh* on boot:

1. Locate your *displaylink.service* file looking at the *Loaded* info:
    ```bash
   systemctl status displaylink.service 
   ```
2. Open the file in your code editor and verify it contains this information:
    ```text
    [Unit]
    Description=DisplayLink Manager Service
    After=display-manager.service
    Wants=display-manager.service
    ```
3. Reload the system daemon and enable the service
    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable displaylink.service 
   ```
4. Modify the display manager configuration. For *sddm* open the configuration file:
    ```bash
   sudo nano /etc/sddm.conf 
   ```
   and write:
   ```text
    [XDisplay]
    DisplayCommand=/path/to/script.sh
   ```
> [!NOTE]
> To know what display manager you have run `systemctl status display-manager.service`

5. Restart the service
    ```bash
   sudo systemctl restart sddm
   ```

> [!IMPORTANT]
> Make sure the file is executable by running `sudo chmod +x /path/to/script`.

> [!TIP]
> If there are any issues you can run `journalctl -u sddm` to see the *sddm* logs.