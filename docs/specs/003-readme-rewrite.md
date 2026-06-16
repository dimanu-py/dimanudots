# 003 - README Rewrite (Bash-Based Approach)

**Status**: Pending  
**Priority**: High  
**Created**: 2026-06-13  

---

## Description

The current `docs/README.md` describes a **legacy Ansible-based approach** (playbooks, roles, `ansible-galaxy`, `--tags`) that no longer exists in this repository. The actual implementation is a **pure bash** modular setup system with GNU Stow for dotfiles.

The README must be completely rewritten to reflect the current architecture, installation flow, project structure, and usage.

---

## Decisions

| Question | Decision |
|----------|----------|
| Language | English only |
| Detail level | Comprehensive reference |
| Table of contents | Yes, with anchor links |
| Screenshots | No |

---

## Acceptance Criteria

- [ ] No references to Ansible, playbooks, roles, `ansible-galaxy`, `--tags`, or `requirements.yml`
- [ ] Documents the actual **bash-based two-phase bootstrap**: `boot.sh` → `install.sh`
- [ ] Documents the **step-based architecture**: packages → dotfiles → desktop → development
- [ ] Documents the **module/sub-module system** under `setup/modules/`
- [ ] Documents the **GNU Stow dotfile deployment** process
- [ ] Documents the **theme system**: structure, switching, adding new themes
- [ ] Documents the **package management flow**: classification, pacman vs yay, dedup
- [ ] Lists all **dotfile packages** that are deployed
- [ ] Covers all **custom scripts** in `~/.local/bin/`
- [ ] Explains **Hyprland config structure**: modular `config/` directory, `config/bindings/`, theme overrides
- [ ] Includes a **project structure tree** showing the directory layout
- [ ] Includes a **quick start** section with the actual `curl | bash` command
- [ ] Documents **step selection** (run specific steps via arguments to `install.sh`)
- [ ] Documents **idempotency** and safety features
- [ ] Documents **prerequisites** (fresh Arch Linux, sudo user, internet)
- [ ] Includes **troubleshooting** section for common issues
- [ ] Includes **maintenance** section (updating, backing up, re-running steps)
- [ ] Table of contents with links to all major sections

---

## Proposed README Structure

```markdown
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
   - [Monitor Setup](#monitor-setup)
   - [Theme Integration](#theme-integration)
10. [Theme System](#theme-system)
    - [Available Themes](#available-themes)
    - [Switching Themes](#switching-themes)
    - [Creating a New Theme](#creating-a-new-theme)
11. [Custom Scripts](#custom-scripts)
12. [Package Management](#package-management)
13. [Idempotency & Safety](#idempotency--safety)
14. [Troubleshooting](#troubleshooting)
15. [Maintenance](#maintenance)
16. [Contributing](#contributing)
17. [License](#license)
```

---

## Content Requirements by Section

### Overview
- What the project is: personal Arch Linux + Hyprland desktop automation
- Target audience: the author, but usable by others after README review
- One-liner describing the philosophy

### Features
- Modular bash-based installer (not Ansible)
- GNU Stow dotfile management
- Full Hyprland desktop with 12+ themes
- Theme-aware components (Waybar, Hyprland, SwayOSD, etc.)
- Development environment setup
- Hardware support (GPU, audio, BT, network)
- Idempotent and safe to re-run

### Quick Start
```bash
curl -fsSL https://raw.githubusercontent.com/dimanu-py/dimanudots/main/boot.sh | bash
```
- Explain what boot.sh does (clones repo, runs install.sh)

### Project Structure
Show the actual tree (simplified):
```
dimanudots/
├── boot.sh           # Bootstrap: clones repo, triggers install
├── install.sh        # Orchestrator: sources steps/modules/libs
├── setup/
│   ├── lib/          # Library functions (pacman, aur, filesystem, systemd)
│   ├── modules/      # Functional modules (packages, dotfiles, desktop, development)
│   └── steps/        # Execution steps (10-packages, 15-dotfiles, etc.)
├── dotfiles/         # Stow packages (hyprland, waybar, zsh, nvim, etc.)
├── themes/           # Theme collections (catppuccin, nord, gruvbox, etc.)
└── docs/
    ├── README.md     # This file
    └── specs/        # Future implementation specifications
```

### Installation Steps
For each step, document:
- What it does
- What scripts it sources
- What files it creates/modifies
- What services it enables

### Dotfiles
- List all stow packages
- Explain the stow command structure
- How to add a new package: create dir under `dotfiles/`, add to `SELECTED_CONFIG_PACKAGES` in `dotfiles.sh`

### Hyprland Configuration
- Document the modular config structure (`config/` directory)
- Document binding categories (applications, media, menu, notifications, system, tiling_management)
- Document monitor configuration approach
- Document theme integration (last source line in hyprland.conf)

### Theme System
- List all 12+ themes
- Explain the symlink structure: `~/.config/themes/active/theme/ → ../../<theme-name>/`
- Explain what each theme provides (hyprland.conf colors, waybar.css, etc.)
- How to switch themes (elephant toggle or manual symlink)

### Custom Scripts
- Table of all scripts in `~/.local/bin/` with descriptions

### Package Management
- Explain the two-tier package list: `packages.core.txt` (bootstrap) vs `packages.base.txt` (everything)
- Explain the classification flow: installed → pacman → yay → unknown
- How to add a new package

### Idempotency & Safety
- Each check before action pattern
- Stow force-override behavior
- Re-running steps is safe

### Troubleshooting
- Common issues and solutions
- Debug mode for install.sh
- How to check logs

### Maintenance
- How to update (re-run install.sh with selective steps)
- How to backup dotfiles
- How to update themes

---

## Implementation Notes

### File to modify
- `docs/README.md` — complete overwrite

### Things to preserve (if any)
- The `curl | bash` one-liner (but point to the actual repo URL)
- The MIT license reference
- General safety and idempotency principles

### Things to remove
- All Ansible references (playbooks, roles, ansible-galaxy, requirements.yml, --tags, --check, --step, -v, --limit)
- The `inventory/group_vars/all.yml` and `inventory/host_vars/localhost.yml` references
- The `roles/` directory structure references
- The `community.general.yay:` module references
- The `# Why ...` sections (can be condensed or removed)

### Things to add
- Actual project structure tree
- GNU Stow explanation
- Theme system documentation
- Step selection via arguments
- Custom scripts catalog
- Hyprland config modular architecture
- Package classification flow

---

## Questions for Future

- Should we create separate documentation files in `docs/` for each major area (themes, scripts, hyprland config) and keep README as a concise overview? (Current spec says comprehensive, but this can be revisited)
- Should we add a `docs/installation.md` with a step-by-step guide for non-personal use?
