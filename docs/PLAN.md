# Arch Linux + Hyprland Desktop Automation Plan

## Phase 1: Bootstrap & Foundation (Tags: bootstrap)
**Goal:** Establish essential tools and idempotent AUR package management

### Tasks:
1. **System Preparation**
   - Update pacman cache
   - Install base-devel, git, wget, curl
   - Install Ansible and required collections

2. **Yay Bootstrap (Idempotent)**
   - Check if yay exists, skip if present
   - Clone yay AUR repository to /tmp/yay-git
   - Build and install yay as non-root user
   - Verify yay installation and cleanup

3. **Ansible Collections Setup**
   - Install community.general collection
   - Verify yay module availability

### Expected Outputs:
- yay command available in PATH
- Ansible can use community.general.yay module
- System ready for role-based configuration

### Verification:
```bash
which yay  # Should return /usr/bin/yay
ansible localhost -m community.general.yay -a "name=tree state=present" --check
```

## Phase 2: Base System Setup (Tags: base)
**Goal:** Install essential system packages and configure basic services

### Tasks:
1. **Essential Packages**
   - System utilities (htop, btop, neofetch, fastfetch)
   - File management (ranger, ncdu, tree)
   - Network tools (networkmanager, openssh)
   - Security (fail2ban, ufw)

2. **User Environment**
   - Install and configure sudo
   - Setup user groups (audio, video, input, etc.)
   - Configure basic shell environment

3. **Filesystem Structure**
   - Create standard directories (Downloads, Documents, etc.)
   - Set proper permissions and ownership

### Expected Outputs:
- All essential packages installed
- User has proper group memberships
- Directory structure created

### Verification:
```bash
pacman -Q htop btop ranger
groups $USER  # Should include audio, video, input
ls -la ~/Downloads/  # Should exist
```

## Phase 3: Hardware Support (Tags: hardware, gpu, audio, bluetooth)
**Goal:** Configure hardware drivers and essential services

### Tasks:
1. **GPU Drivers**
   - Detect GPU type (NVIDIA/AMD/Intel)
   - Install appropriate drivers
   - Configure hardware acceleration

2. **Audio Setup**
   - Install pipewire and components
   - Configure audio permissions
   - Setup Bluetooth audio support

3. **Bluetooth Services**
   - Install bluez and bluez-utils
   - Enable and start bluetooth service
   - Configure auto-power-on

4. **Network Configuration**
   - Setup NetworkManager
   - Install WiFi drivers
   - Configure network services

### Expected Outputs:
- GPU acceleration working
- Audio output functional
- Bluetooth service enabled
- Network connectivity established

### Verification:
```bash
inxi -G  # GPU info
pactl info  # Audio info
systemctl status bluetooth
nmcli device status
```

## Phase 4: Display & Desktop Foundation (Tags: display, fonts, themes)
**Goal:** Setup display manager, fonts, and theming foundation

### Tasks:
1. **Display Manager**
   - Install SDDM
   - Configure SDDM theme
   - Enable display manager service

2. **Font Installation**
   - Install base fonts (dejavu, liberation)
   - Install programming fonts (JetBrains Mono, Fira Code)
   - Install Nerd Fonts and emoji fonts
   - Configure font rendering

3. **Theme Foundation**
   - Install GTK themes (Adwaita-dark)
   - Install icon themes (Papirus, Adwaita)
   - Install cursor themes
   - Configure GTK/QT settings

### Expected Outputs:
- SDDM login screen configured
- Complete font collection installed
- Base theming system ready

### Verification:
```bash
fc-list | grep "JetBrains"  # Font verification
systemctl status sddm
gtk-query-settings  # GTK theme verification
```

## Phase 5: Hyprland Desktop Environment (Tags: hyprland, desktop)
**Goal:** Install and configure complete Hyprland environment

### Tasks:
1. **Core Hyprland**
   - Install hyprland and essential utilities
   - Configure hyprland.conf with sensible defaults
   - Setup environment variables

2. **Desktop Components**
   - Install Waybar (status bar)
   - Install mako (notifications)
   - Install wofi/walker (app launcher)
   - Install swaybg/swaybg (wallpaper)
   - Install hyprlock (screen lock)

3. **Wayland Integration**
   - Install xdg-desktop-portal-hyprland
   - Configure Wayland environment variables
   - Setup clipboard management

4. **Session Management**
   - Install UWSM (Wayland session manager)
   - Configure desktop session
   - Setup autostart applications

### Expected Outputs:
- Fully functional Hyprland desktop
- Working status bar and notifications
- Functional app launcher
- Proper session management

### Verification:
```bash
hyprctl version  # Hyprland installation
waybar --version  # Status bar
uwsm --check  # Session manager
```

## Phase 6: Development Environment (Tags: development, terminal)
**Goal:** Setup development tools and terminal environment

### Tasks:
1. **Terminal Setup**
   - Install terminal emulator (Alacritty/Kitty)
   - Configure shell (Fish/Zsh)
   - Install Starship prompt
   - Setup terminal theming

2. **Development Tools**
   - Install Git and configure global settings
   - Install Python development environment
   - Install Node.js (via fnm or nvm)
   - Install Docker and docker-compose
   - Install Neovim and configure

3. **Additional Tools**
   - Install tmux or zellij
   - Install fzf, fd, ripgrep
   - Install bat (enhanced cat)
   - Configure development shortcuts

### Expected Outputs:
- Productive terminal environment
- Complete development toolchain
- Optimized developer workflow

### Verification:
```bash
alacritty --version  # Terminal
python --version  # Python
node --version  # Node.js
nvim --version  # Editor
```

## Phase 7: Applications & Utilities (Tags: applications)
**Goal:** Install user applications and utilities

### Tasks:
1. **Browsers**
   - Install Firefox/Brave/Chromium
   - Configure Wayland support

2. **Productivity Applications**
   - Install office suite (LibreOffice)
   - Install PDF viewer
   - Install image viewer

3. **Media Applications**
   - Install music player
   - Install video player
   - Install screenshot tools

### Expected Outputs:
- Complete application suite
- All applications properly integrated

## Phase 8: Dotfiles & Final Configuration (Tags: dotfiles)
**Goal:** Deploy personal dotfiles and finalize configuration

### Tasks:
1. **GNU Stow Setup**
   - Install stow package
   - Configure stow for dotfile management

2. **Dotfile Deployment**
   - Clone dotfiles repository
   - Stow configuration files
   - Validate configurations

3. **Final Verification**
   - Test all major components
   - Verify idempotency by re-running playbooks
   - Generate final system report

### Expected Outputs:
- Personal configurations applied
- System fully customized and functional

### Verification:
```bash
stow -d ~/.dotfiles -t ~ config  # Dotfile linking
ansible-playbook site.yml --check  # Idempotency check
```

## Execution Strategy

### Tag Usage:
```bash
# Complete installation
ansible-playbook site.yml

# Phased installation
ansible-playbook site.yml --tags bootstrap,base
ansible-playbook site.yml --tags hardware
ansible-playbook site.yml --tags desktop

# Component-specific
ansible-playbook site.yml --tags hyprland,waybar
ansible-playbook site.yml --tags development
```

### Safety Checks:
- Always run with `--check` first
- Use `--step` for interactive execution
- Verify each phase before proceeding
- Maintain rollback points (git tags)