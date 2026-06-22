# 004 - General Repository Review

**Status**: In Progress  
**Priority**: High  
**Created**: 2026-06-13  

---

## Description

A thorough audit of the repository to detect errors, misconfigurations, dead code, compatibility issues, and improvement opportunities. This document catalogs all findings across scripts, configs, dotfiles, and setup modules.

---

## How to Use This Document

Each section corresponds to a future task that can be fixed independently. After completing all fixes, this spec can be closed.

---

## Structure

- **ERROR**: Will cause breakage at runtime
- **WARNING**: Likely to cause issues or is suboptimal
- **SUGGESTION**: Improvement or cleanup opportunity

---

## 1. Shell Script Errors

### ~~1.1 `monitor-battery` — Missing `fi` (syntax error)~~ ✅ FIXED

### ~~1.2 `monitor-battery` — Wrong timer name~~ ✅ FIXED

### ~~1.3 `battery-monitor.service` — Wrong ExecStart path~~ ✅ FIXED

### 1.4 `hyprland-monitor-watch.service` — Non-existent script (partially fixed)

- **Severity**: ERROR
- **File**: `dotfiles/systemd/.config/systemd/user/hyprland-monitor-watch.service:6`
- **Issue**: The hardcoded `/home/dimanu/` path was replaced with `~/.config/hypr/...`. However:
  - `~` is not expanded in systemd unit file `ExecStart` paths — the path is taken literally
  - The script `monitor_watchdog.sh` still does not exist anywhere in the repo
  - The service is still dead
- **Fix**: Use `%h/.config/...` (systemd user unit specifier for home) instead of `~/.config/...`. Either create the watchdog script, point to a real script, or remove the service entirely.

### ~~1.5 `toggle-idle` — Typo: `uswm-app` → `uwsm-app`~~ ✅ FIXED

### ~~1.6 `take-screenshot` — Typo: `uswm-app` → `uwsm-app`~~ ✅ FIXED

### ~~1.7 `launch-walker` — Typo: `uswm-app` → `uwsm-app` (two instances)~~ ✅ FIXED

### ~~1.8 `launch-floating-terminal-with-presentation` — `show_done` not available in zsh context~~ ✅ FIXED

### ~~1.9 `hyprland-close-all-windows` — Typo: `xarg` → `xargs`~~ ✅ FIXED

### ~~1.10 `autostart.conf` — Typo: `systemclt` → `systemctl`~~ ✅ FIXED

### ~~1.11 `autostart.conf` — Typo: `uwsm app` → `uwsm-app`~~ ✅ FIXED

---

## 2. X11 Compatibility Issues in Wayland Environment

### ~~2.1 `uuidgen.sh` — Uses `xdotool` (X11)~~ ✅ FIXED

- Rewritten as `dotfiles/local/.local/bin/uuidgen` using `wtype` and `wl-copy`. The old `uuidgen.sh` no longer exists.

---

## 3. Dotfile Issues

### ~~3.1 VS Code directory — Runtime garbage~~ ✅ FIXED

- Added gitignore negation patterns: ignore everything under `dotfiles/vs-code/.config/Code/` except `User/settings.json`, `User/keybindings.json`, and `User/snippets/`.

### 3.2 `non-executable scripts` — Missing +x permission (partially fixed)

- **Severity**: WARNING
- **Files**:
  - ~~`dotfiles/local/.local/bin/monitor-battery`~~ ✅ FIXED
  - `dotfiles/local/.local/bin/env` — left as-is (sourced, not executed)
  - `dotfiles/local/.local/bin/env.fish` — left as-is (sourced, not executed)
- **Issue**: `monitor-battery` was missing +x. `env` and `env.fish` are sourced, not executed, so left as 644.

### 3.3 `env` and `env.fish` — Should these be executable?

- **Severity**: SUGGESTION
- **File**: `dotfiles/local/.local/bin/env`, `dotfiles/local/.local/bin/env.fish`
- **Issue**: These are PATH setup scripts. `env` is sourced by `.zshrc`, not executed directly. Making them executable is harmless but unnecessary.
- **Fix**: Confirm intent. If they should only be sourced, leave as-is (but then 3.2 doesn't apply to them).

### ~~3.4 Sway config files (dead code)~~ ✅ FIXED

- Removed `dotfiles/sway/` directory.

### 3.5 SDDM and Plymouth stow packages commented out

- **Severity**: WARNING
- **Files**: `dotfiles/sddm/`, `dotfiles/plymouth/` exist in repo but are commented out in `dotfiles.sh`'s `SELECTED_CONFIG_PACKAGES`.
- **Issue**: Config directories exist but are not deployed. Either they should be deployed or removed.
- **Fix**: If they are active configs (e.g., SDDM is managed via the desktop module), remove the unused stow directories. If they should be stow-deployed, uncomment them.

---

## 4. Path Hardcoding Issues

### ~~4.1 `.zshrc` — Hardcoded `/home/dimanu/` path~~ ✅ FIXED

### ~~4.2 `.gitconfig` — Hardcoded `/home/dimanu/` path~~ ✅ FIXED

### 4.3 VS Code `settings.json` — Stale workspace path

- **Severity**: SUGGESTION
- **File**: `dotfiles/vs-code/.config/Code/User/settings.json:69`
- **Issue**: Contains `"file:///home/dmartinez/.vscode/..."` — references a different user's home directory.
- **Fix**: Remove the stale config entry.

### 4.4 `hyprland-monitor-watch.service` — Hardcoded `/home/dimanu/` path

- **Severity**: ERROR
- **File**: `dotfiles/systemd/.config/systemd/user/hyprland-monitor-watch.service:6`
- **Issue**: Hardcoded absolute path. (Already covered in 1.4.)

---

## 5. Package Management Issues

### ~~5.1 Missing `wtype` package~~ ✅ FIXED

- `wtype` and `grim` have been added to `packages.base.txt`.

### 5.2 Potentially invalid AUR package names

- **Severity**: WARNING
- **File**: `setup/config/packages.base.txt`
- **Issue**: `hyprland-guiutils` is marked as `[AUR]` — the correct package name may differ. Verify existence. `walker-bin-debug` is listed alongside `walker` — confirm if both are needed or if this is redundant.
- **Fix**: Verify package names with `yay -a -Si <pkg>` and correct as needed.

---

## 6. Theme/Config Issues

### 6.1 All `mako.ini` files in themes reference non-existent `omarchy` path

- **Severity**: WARNING
- **Files**: All `themes/*/mako.ini` files (14+ files), each line 1
- **Issue**: `include=~/.local/share/omarchy/default/mako/core.ini` — the system uses `swaync`, not `mako`. And `omarchy` has been largely migrated away from.
- **Fix**: Either remove these files (if `mako` is not used) or update the path.

### 6.2 `omarchy_themes.lua` references non-existent command

- **Severity**: WARNING
- **File**: `dotfiles/elephant/.config/elephant/omarchy_themes.lua:60`
- **Issue**: `activate = "omarchy-theme-set " .. theme_name` — this command does not exist in the current system.
- **Fix**: Create the `omarchy-theme-set` script or update to use the actual theme switching mechanism.

### 6.3 `style_dimanu.css` imports missing `mocha.css`

- **Severity**: WARNING
- **File**: `dotfiles/waybar/.config/waybar/style_dimanu.css:1`
- **Issue**: `@import "themes/mocha.css"` — this file exists only in `ml4w/themes/mocha.css`, not in the top-level waybar config directory.
- **Fix**: Copy `mocha.css` to the correct location, update the import path, or remove the import.

### 6.4 `keybindings-menu` — Stale omarchy path strip

- **Severity**: SUGGESTION
- **File**: `dotfiles/local/.local/bin/keybindings-menu:92`
- **Issue**: `sed -e 's,~/.local/share/omarchy/bin/,,'` — stale omarchy reference. Scripts have moved to `~/.local/bin`.
- **Fix**: Update the sed substitution to also handle `~/.local/bin`.

### 6.5 `swaync/config.json` — Typo in script name

- **Severity**: WARNING
- **File**: `dotfiles/swaync/.config/swaync/config.json:37`
- **Issue**: `dismiss-notifation` (missing 'i') should be `dismiss-notification`.
- **Fix**: Correct the spelling.

---

## 7. Setup Module Issues

### 7.1 `is_in_aur()` in `aur.sh` relies on caller's `$pkg` variable

- **Severity**: WARNING
- **File**: `setup/lib/aur.sh:4`
- **Issue**: Function references `$pkg` which is not passed as a parameter but happens to be the loop variable in `classify.sh`. This breaks if called from any other context.
- **Fix**: Change to accept `$1` as a parameter: `is_in_aur() { local pkg="$1"; yay -a -Si "$pkg" >/dev/null 2>&1; }`.

### 7.2 `collect-packages.sh` returns error but callers don't check exit code

- **Severity**: SUGGESTION
- **File**: `setup/modules/packages/collect-packages.sh:69` → `install-packages.sh:9`
- **Issue**: `_ensure_there_are_packages` returns `1` on empty list, but the caller doesn't check the exit code.
- **Fix**: Add exit code check after `collect_packages` call.

---

## 8. Git Repository Issues

### 8.1 Large binaries tracked in git

- **Severity**: WARNING
- **Files**: `dotfiles/local/.local/bin/uv` (56MB binary), `dotfiles/local/.local/bin/uvx` (360KB), `dotfiles/local/.local/bin/python3.1*` (symlinks to uv-managed Python)
- **Issue**: Large binaries bloat the repo and the symlinks point to uv-managed Python installations that may not exist on other machines.
- **Fix**: Remove from the dotfiles repo and have the setup script install them instead. Add to `.gitignore`.

### 8.2 `.gitignore` is too minimal (partially fixed)

- **Severity**: SUGGESTION
- **File**: `.gitignore`
- **Issue**: Missing patterns for:
  - ~~VS Code runtime data (Cache, logs, databases, etc.)~~ ✅ FIXED — added negation patterns
  - `*.bakup` files (see `config.bakup`)
  - `.env` files
- **Fix**: Add remaining ignore patterns.

### 8.3 `boot.sh` — Unquoted variable

- **Severity**: SUGGESTION
- **File**: `boot.sh:27`
- **Issue**: `chmod +x $CLONE_DIR/install.sh` — path not quoted.
- **Fix**: Use `chmod +x "$CLONE_DIR/install.sh"`.

---

## 9. Minor Issues

### 9.1 `ivm/config` — Typos in variable names

- **Severity**: SUGGESTION
- **File**: `dotfiles/ivm/.config/ivm/config:3,9`
- **Issue**: `$imv_current_fiel` should be `$imv_current_file` (missing 'e' in `file`).
- **Fix**: Fix the variable names.

### 9.2 `toggle-nightlight` — Local variable shadows function name

- **Severity**: SUGGESTION
- **File**: `dotfiles/local/.local/bin/toggle-nightlight:49-50`
- **Issue**: `local get_current_screen_temperature` declares a local variable with the same name as the function. Then `current_temperature=$(get_current_screen_temperature)` uses `current_temperature` (missing `local`), and the function call overwrites the local variable.
- **Fix**: Remove `local` from line 49 (the function declaration), or rename the variable.

### 9.3 `gitconfig/.gitconfig` — Mixed tabs/spaces

- **Severity**: SUGGESTION
- **File**: `dotfiles/gitconfig/.gitconfig:8,31-33`
- **Issue**: Lines use tabs instead of spaces, inconsistent with the rest of the file.
- **Fix**: Normalize to spaces.

### 9.4 `launch-webapp` — Fragile `xdg-settings` parsing

- **Severity**: SUGGESTION
- **File**: `dotfiles/local/.local/bin/launch-webapp:3-9`
- **Issue**: Parses the default browser's `.desktop` file to extract the Exec line. This fails for Snap/Flatpak browsers or browsers with complex Exec lines.
- **Fix**: Consider using `xdg-open` directly, or hardcoding the browser.

### 9.5 `pdm` script — Hardcoded absolute shebang

- **Severity**: SUGGESTION
- **File**: `dotfiles/local/.local/bin/pdm:1`
- **Issue**: `#!/home/dimanu/.local/share/pdm/venv/bin/python` — will break for any other user or after PDM reinstall.
- **Fix**: Remove from dotfiles and install via setup script, or use `#!/usr/bin/env python3`.

### 9.6 Waybar ml4w config — Dead or active?

- **Severity**: SUGGESTION
- **Directory**: `dotfiles/waybar/.config/waybar/ml4w/`
- **Issue**: Contains a complete separate Waybar config that may conflict with the main `config.jsonc`. Unclear if actively used.
- **Fix**: Document whether ml4w is actively used, or remove if dead.

### 9.7 `applications.conf` — Commented-out screen recording bindings

- **Severity**: SUGGESTION
- **File**: `dotfiles/hyprland/.config/hypr/config/bindings/applications.conf:17-18`
- **Issue**: Commented-out binds reference `omarchy-cmd-screenrecord` which may not be installed.
- **Fix**: Remove commented code or update with working screen recording solution.

---

## 10. Setup Module Errors — Snapshots

### 10.1 `snapshots.sh` — `timeshift --btrfs` is interactive, will hang on fresh install

- **Severity**: ERROR
- **File**: `setup/modules/desktop/snapshots.sh:31`
- **Issue**: `sudo timeshift --btrfs` runs timeshift in interactive mode. On a fresh system with no timeshift config, it will prompt the user to select a snapshot device/location. The setup script is non-interactive, so this command hangs indefinitely.
- **Fix**: Pre-place a pre-configured `timeshift.json` at `/etc/timeshift/timeshift.json` (using the existing `setup/config/timeshift-example.json` as a template) before running `timeshift --btrfs`, so it runs non-interactively.

### 10.2 `snapshots.sh` — Unquoted variable in filesystem check

- **Severity**: WARNING
- **File**: `setup/modules/desktop/snapshots.sh:12`
- **Issue**: `_file_system_is_not_btrfs $file_path` — `$file_path` is not quoted. If this function is ever called with a path containing spaces (e.g., a bind mount), the argument will split.
- **Fix**: Change to `_file_system_is_not_btrfs "$file_path"`.

### 10.3 `snapshots.sh` — Runs grub hook script directly

- **Severity**: ERROR
- **File**: `setup/modules/desktop/snapshots.sh:57`
- **Issue**: `sudo /etc/grub.d/41_snapshots-btrfs` runs the grub-btrfs hook directly. This script is designed to be called by `grub-mkconfig`, not executed standalone. Running it directly may produce unexpected output or errors. Additionally, the script may not exist or be executable if the `grub-btrfs` package is not installed.
- **Fix**: Remove this direct call — `grub-mkconfig` on line 61 already invokes all hooks in `/etc/grub.d/`. Or, if a separate step is needed, use `bash /etc/grub.d/41_snapshots-btrfs` and add a package check for `grub-btrfs`.

### 10.4 `snapshots.sh` — No prerequisite package checks

- **Severity**: WARNING
- **File**: `setup/modules/desktop/snapshots.sh:31,57,61,67`
- **Issue**: The script calls `timeshift`, `grub-mkconfig`, and references `/etc/grub.d/41_snapshots-btrfs` and `/etc/systemd/system/grub-btrfsd.service` without verifying the required packages are installed (`timeshift`, `grub-btrfs`, `grub`).
- **Fix**: Add checks that required commands exist before running them, or ensure these packages are listed as dependencies earlier in the setup.

### 10.5 `snapshots.sh` — JSON editing with sed is fragile

- **Severity**: WARNING
- **File**: `setup/modules/desktop/snapshots.sh:39-46`
- **Issue**: `sudo sed -i` modifies `/etc/timeshift/timeshift.json` using regex substitutions. JSON is not a regular language — sed patterns can break if:
  - Key names or value formats differ across timeshift versions
  - The JSON formatting changes (e.g., different indentation)
  - New keys are added between existing ones
- **Fix**: Use `jq` for JSON manipulation, or use the pre-configured `timeshift-example.json` template directly.

### 10.6 `snapshots.sh` — Never uses the existing `timeshift-example.json` template

- **Severity**: SUGGESTION
- **File**: `setup/config/timeshift-example.json` (unused)
- **Issue**: A pre-configured `timeshift.json` template exists at `setup/config/timeshift-example.json` but is never referenced by the snapshots setup script. It could be used to bootstrap the timeshift config non-interactively.
- **Fix**: Either use the template in `snapshots.sh` (copy to `/etc/timeshift/timeshift.json` before calling `timeshift --btrfs`), or remove the orphaned file.

---

| Priority | Issue | Status | Effort |
|----------|-------|--------|--------|
| P0 | 1.1 `monitor-battery` syntax error | ✅ FIXED | — |
| P0 | 1.5-1.7 `uswm-app` typos | ✅ FIXED | — |
| P0 | 1.8 `show_done` not available in zsh context | ✅ FIXED | — |
| P0 | 1.9 `xarg` typo | ✅ FIXED | — |
| P0 | 1.10 `systemclt` typo | ✅ FIXED | — |
| P0 | 1.11 `autostart.conf` `uwsm app` typo | ✅ FIXED | — |
| P0 | 4.1 `.zshrc` hardcoded path | ✅ FIXED | — |
| P1 | 1.2-1.3 Wrong timer/service names | ✅ FIXED | — |
| P1 | 1.4 Dead systemd service | ⏸️ PARTIALLY FIXED | — |
| P1 | 2.1 `uuidgen.sh` X11 tool | ✅ FIXED | — |
| P1 | 5.1 Missing `wtype`/`grim` packages | ✅ FIXED | — |
| P1 | 4.2 `.gitconfig` hardcoded path | ✅ FIXED | — |
| P2 | 3.1 VS Code runtime garbage | ✅ FIXED | — |
| P2 | 3.2 Non-executable scripts (+x perms) | ✅ FIXED | — |
| P2 | 3.4 Sway dead code | ✅ FIXED | — |
| P2 | 3.5 Commented-out stow packages | 🔴 OPEN | 5 min |
| P2 | 6.1-6.5 Theme/config issues | 🔴 OPEN | Various |
| P2 | 7.1 `is_in_aur()` variable scoping | 🔴 OPEN | 2 lines |
| P3 | 8.1 Large binaries in git (uv/uvx/python) | 🔴 OPEN | 10 min |
| P3 | 8.2 `.gitignore` improvements (bakup, .env) | 🔴 OPEN | 5 min |
| P3 | 8.3 `boot.sh` unquoted variable | 🔴 OPEN | 1 line |
| P4 | 9.1-9.7 Minor issues | 🔴 OPEN | Various |
| P1 | 10.1 Snapshots — timeshift interactive | 🔴 OPEN | 1 file |
| P1 | 10.3 Snapshots — grub hook direct call | 🔴 OPEN | 1 line |
| P2 | 10.2 Snapshots — unquoted variable | 🔴 OPEN | 1 line |
| P2 | 10.4 Snapshots — missing package checks | 🔴 OPEN | 5 lines |
| P2 | 10.5 Snapshots — fragile JSON editing | 🔴 OPEN | 5 lines |
| P3 | 10.6 Snapshots — unused template file | 🔴 OPEN | 1 line |

---

## Verification

After fixing, run:
- `bash -n` on all `.sh` scripts to verify syntax
- `shellcheck` on all `.sh` scripts for best practices
- Verify Hyprland loads without errors: `hyprctl reload`
- Test each affected script manually
- `git status` to confirm no unintended files tracked
