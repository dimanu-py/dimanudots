# dimanudots

> A fully automated Arch Linux + Hyprland desktop environment setup and dotfiles management system.

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Prerequisites](#prerequisites)
4. [Quick Start](#quick-start)
5. [Project Structure](#project-structure)
6. [Installation Steps](#installation-steps)
   - [10-packages](#10-packages)
   - [15-dotfiles](#15-dotfiles)
   - [20-desktop](#20-desktop)
   - [30-development-tools](#30-development-tools)
7. [Step Selection](#step-selection)
8. [Dotfiles](#dotfiles)
   - [What Gets Stowed](#what-gets-stowed)
   - [How to Add a New Package](#how-to-add-a-new-package)
9. [Hyprland Configuration](#hyprland-configuration)
   - [Config Structure](#config-structure)
   - [Keybindings](#keybindings)
   - [Theme Integration](#theme-integration)
10. [Theme System](#theme-system)
    - [Available Themes](#available-themes)
    - [How It Works](#how-it-works)
    - [Switching Themes](#switching-themes)
    - [Creating a New Theme](#creating-a-new-theme)
11. [Custom Scripts](#custom-scripts)
12. [Package Management](#package-management)
    - [Package Lists](#package-lists)
    - [Classification Flow](#classification-flow)
    - [Adding a Package](#adding-a-package)
13. [Idempotency & Safety](#idempotency--safety)
14. [Troubleshooting](#troubleshooting)
15. [Maintenance](#maintenance)

---

## Overview

dimanudots is a personal Arch Linux desktop automation system. It provisions a full Hyprland-based environment from a fresh Arch install in minutes — packages, dotfiles, themes, and development tools — using a modular bash-based installer and GNU Stow for config management.

The project is designed for its author but structured to be understandable and adaptable by others.

---

## Features

- **Modular bash-based installer** — four independent steps run sequentially or selectively
- **GNU Stow dotfile management** — atomic symlink deployment per package
- **Full Hyprland desktop** — Wayland-native compositor with 14 built-in themes
- **Theme-aware components** — Waybar, Hyprland, Hyprlock, SwayOSD, Walker, Ghostty, Btop, Neovim, VS Code
- **Automatic hardware support** — GPU drivers, Pipewire audio, Bluetooth, networking
- **Package management** — dual pacman + yay (AUR) classification, deduplication
- **Idempotent** — safe to re-run without breaking existing configuration
- **Development environment** — Python (uv), Node.js, Docker, Git, Neovim

---

## Prerequisites

1. **Fresh Arch Linux installation** — base system with a user account and sudo access
2. **Internet connection** — required for package downloads
3. **Btrfs filesystem on /** — required for Timeshift snapshot support (optional)

---

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/dimanu-py/dimanudots/main/boot.sh | bash
```

This clones the repo to `~/.local/share/dimanudots` and runs `install.sh` which executes all four setup steps in order.

---

## Project Structure

```
~/.local/share/dimanudots/
├── boot.sh                 # Bootstrap: installs git, clones repo, triggers install.sh
├── install.sh              # Orchestrator: sources library, modules, and runs steps
├── setup/
│   ├── lib/                # Reusable library functions
│   │   ├── pacman.sh       #   pacman_install(), is_installed(), is_in_official_repos()
│   │   ├── aur.sh          #   yay_install(), is_in_aur()
│   │   ├── file_system.sh  #   sym_link_file(), ensure_file_exists(), create_directory()
│   │   ├── systemd.sh      #   enable_service()
│   │   ├── command.sh      #   run_installer(), verify_command_exists()
│   │   └── error.sh        #   die()
│   ├── modules/            # Functional modules implementing each step
│   │   ├── packages/       #   Package install, yay setup, package classification
│   │   ├── dotfiles/       #   Stow orchestration
│   │   └── desktop/        #   Themes, wallpapers, display manager, snapshots
│   ├── steps/              # Step definitions that wire modules together
│   │   ├── 10-packages.sh
│   │   ├── 15-dotfiles.sh
│   │   ├── 20-desktop.sh
│   │   └── 30-development-tools.sh
│   └── config/
│       ├── packages.core.txt    # Bootstrap packages (installed via pacman)
│       └── packages.base.txt    # All remaining packages (pacman + AUR)
├── dotfiles/               # Stow packages — each directory is a stow root
│   ├── hyprland/
│   ├── waybar/
│   ├── zsh/
│   ├── nvim/
│   ├── local/              # ~/.local/bin scripts
│   └── ...                 # 20+ packages total
├── themes/                 # Theme collection (14 themes)
│   ├── tokyo-night/
│   ├── catppuccin/
│   ├── nord/
│   └── ...
└── docs/
    ├── README.md           # This file
    └── specs/              # Implementation specifications
```

---

## Installation Steps

### 10-packages

**What it does:** Installs all required packages on a fresh system.

1. Installs core packages from `packages.core.txt` via pacman (git, base-devel, python, stow, etc.)
2. Builds and installs `yay` from AUR if not present (for AUR package support)
3. Installs all remaining packages from `packages.base.txt` — each is classified as already-installed, pacman-installable, yay-installable, or unknown

**Files:** `setup/steps/10-packages.sh`, `setup/modules/packages/`

### 15-dotfiles

**What it does:** Deploys all dotfiles using GNU Stow.

For each package in the `SELECTED_CONFIG_PACKAGES` array, it runs `stow --target $HOME <package>` inside the `dotfiles/` directory. If files already exist at the target, stow retries with `--override='.*'` to force-overwrite.

**Files:** `setup/steps/15-dotfiles.sh`, `setup/modules/dotfiles/dotfiles.sh`

### 20-desktop

**What it does:** Configures the desktop environment.

1. Creates standard base directories (Desktop, Downloads, etc.)
2. Clones wallpaper repository to `~/Pictures/wallpapers/`
3. Enables Bluetooth and NetworkManager services
4. Configures SDDM display manager
5. Symlinks all themes to `~/.config/themes/` and sets the initial theme (tokyo-night)
6. Configures GTK theme, icons, and color scheme
7. Sets up Timeshift snapshots (requires Btrfs)

**Sources:** `setup/modules/desktop/` — base-directories, bluetooth, network, display-manager, themes, wallpapers, snapshots

**Files:** `setup/steps/20-desktop.sh`

### 30-development-tools

**What it does:** Installs development tooling.

1. Installs `uv` (Python package manager)
2. Installs `opencode` (AI coding assistant)
3. Configures Git aliases and delta diff viewer
4. Enables and starts Docker service

**Files:** `setup/steps/30-development-tools.sh`, `setup/modules/development/`

---

## Step Selection

Run only specific steps by passing them as arguments:

```bash
# Only deploy dotfiles
./install.sh dotfiles

# Install packages and development tools
./install.sh packages development-tools

# Full install (all steps)
./install.sh
```

Available steps: `packages`, `dotfiles`, `desktop`, `development-tools`

---

## Dotfiles

Dotfiles are managed with [GNU Stow](https://www.gnu.org/software/stow/). Each subdirectory under `dotfiles/` is a stow package — the directory tree mirrors `$HOME`:

```
dotfiles/btop/.config/btop/btop.conf  →  ~/.config/btop/btop.conf
dotfiles/zsh/.zshrc                    →  ~/.zshrc
dotfiles/hyprland/.config/hypr/       →  ~/.config/hypr/
```

### What Gets Stowed

| Package | Target | Description |
|---------|--------|-------------|
| bat | `~/.config/bat/` | Bat syntax highlighting theme |
| btop | `~/.config/btop/` | System monitor with theme integration |
| elephant | `~/.config/elephant/` | Calculator launcher config |
| fastfetch | `~/.config/fastfetch/` | System info tool |
| fcitx5 | `~/.config/fcitx5/` | Input method framework |
| flameshot | `~/.config/flameshot/` | Screenshot tool (grim adapter) |
| ghostty | `~/.config/ghostty/` | Terminal emulator |
| hyprland | `~/.config/hypr/` | Window manager config |
| ivm | `~/.config/ivm/` | Image viewer config |
| local | `~/.local/bin/` | Custom scripts |
| nvim | `~/.config/nvim/` | Neovim editor |
| starship | `~/.config/starship/` | Shell prompt |
| swaync | `~/.config/swaync/` | Notification daemon |
| swayosd | `~/.config/swayosd/` | On-screen display |
| systemd | `~/.config/systemd/user/` | User systemd services |
| typora | `~/.config/typora/` | Markdown editor |
| uwsm | `~/.config/uwsm/` | Wayland session manager |
| vs-code | `~/.config/Code/` | VS Code editor (only User/settings.json + keybindings) |
| walker | `~/.config/walker/` | Application launcher |
| waybar | `~/.config/waybar/` | Status bar |
| zsh | `~/.zshrc` | Shell config |

### How to Add a New Package

1. Create a directory under `dotfiles/<name>/` mirroring the target path
2. Add `"<name>"` to the `SELECTED_CONFIG_PACKAGES` array in `setup/modules/dotfiles/dotfiles.sh`
3. Run `stow --target "$HOME" <name>` from the `dotfiles/` directory

---

## Hyprland Configuration

### Config Structure

```
~/.config/hypr/
├── hyprland.conf          # Main entry point
├── hypridle.conf          # Idle/lock settings
├── hyprlock.conf          # Lock screen appearance
├── hyprsunset.conf        # Night light settings
└── config/
    ├── monitors.conf      # Monitor layouts
    ├── autostart.conf     # Startup applications
    └── bindings/
        ├── applications.conf   # App launch keybinds
        ├── media.conf          # Media/volume controls
        ├── menu.conf           # Launcher/menu keybinds
        ├── notifications.conf  # Notification toggles
        ├── system.conf         # System actions (lock, power)
        └── tiling_management.conf  # Window management
```

The config is modular: `hyprland.conf` sources each file from the `config/` directory, and the theme system overrides colors via symlinked `config/themes/active/theme/hyprland.conf`.

### Keybindings

| Category | File | Examples |
|----------|------|----------|
| Applications | `applications.conf` | Browser, terminal, file manager, launcher |
| Media | `media.conf` | Volume, brightness, media playback |
| Menu | `menu.conf` | Power menu, keybindings menu, clipboard |
| Notifications | `notifications.conf` | DND toggle, notification center |
| System | `system.conf` | Lock screen, logout, battery check |
| Tiling | `tiling_management.conf` | Window movement, resize, workspace management |

### Theme Integration

The last line in `hyprland.conf` sources `~/.config/themes/active/theme/hyprland.conf`, which overrides border colors and other theme-specific values. See [Theme System](#theme-system) for details.

---

## Theme System

14 themes are built in. Each theme provides colors and assets for all desktop components.

### Available Themes

catppuccin, catppuccin-latte, ethereal, everforest, flexoki-light, gruvbox, hackerman, kanagawa, matte-black, nord, osaka-jade, ristretto, rose-pine, tokyo-night

### How It Works

Themes use a two-level symlink structure:

```
~/.config/themes/tokyo-night/  →  <repo>/themes/tokyo-night/      (symlink)
~/.config/themes/active/
  ├── theme/                   →  ~/.config/themes/tokyo-night/   (symlink)
  └── background               →  ~/.config/themes/tokyo-night/backgrounds/1-tokyo-night.jpg
```

Each theme provides:

| File | Used By |
|------|---------|
| `hyprland.conf` | Border colors, active window hints |
| `hyprlock.conf` | Lock screen colors |
| `waybar.css` | Status bar colors (`@foreground`, `@background`) |
| `swayosd.css` | On-screen display styling |
| `walker.css` | Application launcher theme |
| `ghostty.conf` | Terminal colors |
| `btop.theme` | System monitor colors |
| `neovim.lua` | Editor colorscheme |
| `vscode.json` | VS Code theme (manual import) |
| `backgrounds/` | Wallpaper images |

Components reference the active theme via symlinks:

- Waybar: `@import "../themes/active/theme/waybar.css"`
- Hyprland: `source = ~/.config/themes/active/theme/hyprland.conf`
- Btop: `~/.config/btop/themes/active.theme` → `active/theme/btop.theme`
- swaybg: `~/.config/themes/active/background`

### Switching Themes

Run the theme switcher script:

```bash
theme-switcher
```

This opens a Walker dmenu with all available themes, preselected to the current one. Selecting a theme updates the `active/theme` and `active/background` symlinks.

### Creating a New Theme

1. Copy an existing theme: `cp -r themes/tokyo-night themes/my-theme`
2. Update `waybar.css` with your `@define-color foreground` and `@define-color background`
3. Update each component config file with your colors
4. Add a background image to `backgrounds/`
5. Run `./install.sh dotfiles` — the setup script symlinks the new theme to `~/.config/themes/`

---

## Custom Scripts

All custom scripts are installed to `~/.local/bin/` via the `local` stow package.

| Script | Description |
|--------|-------------|
| `battery-remaining` | Show battery percentage via upower |
| `check-wifi` | Check Wi-Fi connection status |
| `dismiss-notification` | Dismiss swaync notification |
| `hyprland-close-all-windows` | Close all windows and go to workspace 1 |
| `keybindings-menu` | Show Hyprland keybindings in Walker dmenu |
| `launch-bluetooth` | Open Bluetooth manager |
| `launch-floating-terminal-with-presentation` | Run a command in a floating terminal with completion spinner |
| `launch-or-focus` | Launch or focus an application by class name |
| `launch-or-focus-tui` | Same for terminal apps |
| `launch-tui` | Launch a terminal application |
| `launch-walker` | Start/launch Walker application launcher |
| `launch-webapp` | Open a URL as a web app in the default browser |
| `launch-wifi` | Open Wi-Fi network manager |
| `lock-screen` | Lock the screen via hyprlock |
| `monitor-battery` | Set power profile and enable battery monitoring timer |
| `power-menu` | Shutdown, reboot, or suspend via Walker dmenu |
| `power-profiles-menu` | Switch power profiles via Walker dmenu |
| `restart-waybar` | Restart the Waybar status bar |
| `start-elephant` | Start elephant calculator launcher |
| `take-screenshot` | Launch flameshot for interactive screenshot |
| `theme-switcher` | Switch active theme via Walker dmenu |
| `toggle-dnd` | Toggle Do Not Disturb in swaync |
| `toggle-idle` | Toggle hypridle (auto-lock on idle) |
| `toggle-nightlight` | Toggle hyprsunset night light temperature |
| `tz-select` | Select timezone via Walker dmenu |
| `uuid-menu` | Generate UUID (v4 or v7), copy to clipboard, and type |

---

## Package Management

### Package Lists

| File | Contents | Install Method |
|------|----------|----------------|
| `setup/config/packages.core.txt` | Bootstrap essentials (git, base-devel, python, go, stow) | pacman |
| `setup/config/packages.base.txt` | Everything else (system tools, Hyprland, apps, dev tools) | pacman + yay |

### Classification Flow

When `install_packages` runs, each package is classified using this logic:

```
is_installed? → if yes, skip
is_in_official_repos? → if yes, install via pacman
is_in_aur? → if yes, install via yay
otherwise → print warning and skip
```

### Adding a Package

1. Add the package name to `setup/config/packages.base.txt` (or `packages.core.txt` for bootstrap essentials)
2. Optionally add a comment for context: `package-name  # Purpose of the package`
3. If it's an AUR package, add `[AUR]` to the comment for clarity
4. Run `./install.sh packages` to install

---

## Idempotency & Safety

- **Package classification** skips already-installed packages
- **Stow overrides** existing files only when explicitly needed (`--override='.*'`)
- **Step selection** allows re-running only the steps that changed
- **Library functions** check state before acting (e.g., `is_installed()`)
- **Systemd services** are enabled idempotently (skip if already enabled)
- **No destructive defaults** — the installer never removes packages or files

---

## Troubleshooting

### Stow conflicts

If stow refuses to symlink because a file already exists:

```bash
cd ~/.local/share/dimanudots/dotfiles
stow --target "$HOME" --override='.*' <package>
```

### AUR build failures

```bash
yay -Scc && yay -Syu
```

### Step fails midway

Fix the issue and re-run only the failed step:

```bash
./install.sh <step-name>
```

### Check what a step does

Read the step file directly:

```bash
cat setup/steps/10-packages.sh
```

---

## Maintenance

### Update dotfiles

```bash
cd ~/.local/share/dimanudots
git pull --rebase
./install.sh dotfiles
```

### Re-run package installation

```bash
./install.sh packages
```

### Backup

Dotfiles are in the git repository — push to your fork:

```bash
cd ~/.local/share/dimanudots
git add -A
git commit -m "update dotfiles"
git push
```

---
