# Arch Linux + Hyprland Desktop Automation

A comprehensive Ansible project for fully automating the installation and configuration of an Arch Linux desktop environment with Hyprland.

## Features

- 🚀 **Idempotent Automation** - Safe to re-run without breaking
- 🧩 **Modular Design** - Enable/disable components as needed
- 🎯 **Best Practices** - Follows Ansible and Arch Linux conventions
- 🔧 **Hardware Support** - Automatic GPU/Audio/Bluetooth setup
- 🎨 **Complete Desktop** - Hyprland + theming + applications
- 💻 **Dev Ready** - Full development environment included

## Quick Start

### Prerequisites

1. **Fresh Arch Linux Installation** - Minimal base install with user account
2. **User with Sudo Access** - User must be in sudoers group
3. **Internet Connection** - Required for package downloads

### Bootstrap Ansible

```bash
# Install Ansible on Arch
sudo pacman -Syu ansible python

# Clone this repository
git clone https://github.com/yourusername/dimanudots.git
cd dimanudots

# Install Ansible collections
ansible-galaxy install -r requirements.yml
```

### Full System Setup

```bash
# Run complete installation (takes ~30-60 minutes)
ansible-playbook playbooks/site.yml

# Or run phases progressively
ansible-playbook playbooks/site.yml --tags bootstrap,base
ansible-playbook playbooks/site.yml --tags hardware
ansible-playbook playbooks/site.yml --tags desktop
ansible-playbook playbooks/site.yml --tags development
```

## Modular Execution

### Tags Overview

| Tag | Component | Purpose |
|-----|-----------|---------|
| `bootstrap` | Foundation | Yay, base tools, Ansible collections |
| `base` | System | Essential packages, user setup |
| `hardware` | Hardware | GPU, audio, bluetooth, network |
| `display` | Display | SDDM, fonts, themes |
| `hyprland` | Desktop | Hyprland WM and desktop components |
| `development` | Dev Tools | Terminal, editors, development stack |
| `applications` | Apps | User applications and utilities |
| `dotfiles` | Config | Personal dotfiles and finalization |

### Common Usage Patterns

```bash
# Desktop environment only
ansible-playbook playbooks/desktop.yml --tags hyprland

# Development environment only
ansible-playbook playbooks/development.yml

# Specific components
ansible-playbook playbooks/site.yml --tags audio,bluetooth

# Update specific packages
ansible-playbook playbooks/site.yml --tags development --extra-vars "update_packages=true"
```

## Configuration

### Variables

Global variables are in `inventory/group_vars/all.yml`:

```yaml
# User configuration
user: "{{ lookup('env', 'USER') }}"
home: "{{ lookup('env', 'HOME') }}"

# Hardware preferences
gpu_driver: "auto"  # auto, nvidia, amdgpu, intel
audio_backend: "pipewire"  # pipewire, pulseaudio

# Desktop preferences
desktop_environment: "hyprland"
terminal_emulator: "alacritty"
shell: "fish"

# Development tools
python_version: "3.12"
nodejs_version: "lts"
enable_docker: true
```

### Customization

Create `inventory/host_vars/localhost.yml` for per-machine overrides:

```yaml
# Override default values here
gpu_driver: "nvidia"
terminal_emulator: "kitty"
enable_docker: false
```

## AUR Package Management (Yay)

This project uses Yay for AUR packages with full idempotency:

### Bootstrap Process

1. **Yay Installation** - Built from AUR if not present
2. **Idempotent Check** - Skips if already installed
3. **Cleanup** - Removes build artifacts after installation

### Usage

```yaml
# In roles
- name: Install AUR package
  community.general.yay:
    name: package-name
    state: present
    become: false  # Run as user for AUR packages
```

### Safety Features

- **Non-root execution** for AUR packages
- **Build cleanup** to save disk space
- **Idempotent checks** to prevent reinstallation
- **Error handling** for build failures

## Component Rationale

### Why Hyprland?
- **Performance**: Lightweight and responsive
- **Wayland Native**: Modern display server with better security
- **Customization**: Extensive configuration options
- **Active Development**: Regular updates and community support

### Why Pipewire?
- **Modern Audio**: Replaces Pulseaudio with better performance
- **Bluetooth**: Native Bluetooth audio support
- **Low Latency**: Better for professional audio work
- **Compatibility**: Drop-in replacement for Pulseaudio

### Why SDDM?
- **Wayland Support**: Native Wayland session management
- **Themeable**: Customizable login screen
- **Secure**: Proper authentication handling
- **Standard**: Widely used in Linux distributions

### Why Development Tools?
- **Python**: Essential for scripting and automation
- **Node.js**: Web development and tooling
- **Docker**: Containerization for development
- **Git**: Version control for projects
- **Neovim**: Powerful terminal editor

## Safety and Idempotency

### Design Principles

1. **Check Before Action** - Verify state before making changes
2. **Use Handlers** - Restart services only when needed
3. **Idempotent Modules** - Prefer built-in idempotency
4. **Rollback Safety** - Maintain system stability

### Safety Commands

```bash
# Dry run (recommended first)
ansible-playbook playbooks/site.yml --check

# Step-by-step execution
ansible-playbook playbooks/site.yml --step

# Verbose output for debugging
ansible-playbook playbooks/site.yml -v

# Limit to specific hosts
ansible-playbook playbooks/site.yml --limit localhost
```

## Troubleshooting

### Common Issues

1. **Yay Permission Denied**
   ```bash
   # Fix ownership of yay build directory
   sudo chown -R $USER:users /tmp/yay-git
   ```

2. **AUR Build Failures**
   ```bash
   # Clean and rebuild
   yay -Scc && yay -Syu
   ```

3. **Permission Issues**
   ```bash
   # Ensure user in required groups
   sudo usermod -aG audio,video,input,wheel $USER
   ```

4. **Wayland Application Issues**
   ```bash
   # Check Wayland support
   echo $XDG_SESSION_TYPE
   # Should output "wayland"
   ```

### Debug Mode

```bash
# Enable debug logging
ANSIBLE_DEBUG=1 ansible-playbook playbooks/site.yml -v
```

## Maintenance

### Updates

```bash
# Update system
ansible-playbook playbooks/site.yml --tags update

# Update specific components
ansible-playbook playbooks/site.yml --tags development --extra-vars "update_packages=true"
```

### Backup

```bash
# Backup dotfiles
stow -d ~/.dotfiles -t ~ -D  # Unstow
cp -r ~/.config ~/dotfiles-backup/
```

## Contributing

1. Fork the repository
2. Create feature branch
3. Test with `--check` mode
4. Ensure idempotency
5. Submit pull request

## License

MIT License - See LICENSE file for details