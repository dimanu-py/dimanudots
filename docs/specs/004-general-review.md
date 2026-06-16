# 004 - General Repository Review

**Status**: Pending  
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

### 1.1 `monitor-battery` — Missing `fi` (syntax error)

- **Severity**: ERROR
- **File**: `dotfiles/local/.local/bin/monitor-battery:12`
- **Issue**: The `set_initial_power_profile()` function is missing the closing `fi` for the `if` block, and the function closing `}` is misplaced. `bash -n` confirms a syntax error.
- **Current code** (lines 7-12):
  ```bash
  set_initial_power_profile() {
      if runs_on_battery; then
          powerprofilesctl set balanced || true
      else
          powerprofilesctl set performance || true
  }
  ```
- **Fix**: Add `fi` before `}`:
  ```bash
  set_initial_power_profile() {
      if runs_on_battery; then
          powerprofilesctl set balanced || true
      else
          powerprofilesctl set performance || true
      fi
  }
  ```

### 1.2 `monitor-battery` — Wrong timer name

- **Severity**: ERROR
- **File**: `dotfiles/local/.local/bin/monitor-battery:15`
- **Issue**: Calls `systemctl --user enable --now battery-watchdog.timer` but the actual systemd file is named `battery-monitor.timer`.
- **Fix**: Change to `systemctl --user enable --now battery-monitor.timer`.

### 1.3 `battery-monitor.service` — Wrong ExecStart path

- **Severity**: ERROR
- **File**: `dotfiles/systemd/.config/systemd/user/battery-monitor.service:7`
- **Issue**: `ExecStart=%h/.local/share/dimanu/bin/battery-monitor` — this path does not exist. The actual script is at `~/.local/bin/monitor-battery`.
- **Fix**: Change to `ExecStart=%h/.local/bin/monitor-battery`.

### 1.4 `hyprland-monitor-watch.service` — Non-existent script

- **Severity**: ERROR
- **File**: `dotfiles/systemd/.config/systemd/user/hyprland-monitor-watch.service:6`
- **Issue**: `ExecStart=/home/dimanu/.config/hypr/conf/monitors/monitor_watchdog.sh` — this file does not exist anywhere in the repo. The whole service is dead.
- **Fix**: Either create the watchdog script, update to point to a real script, or remove the service entirely.

### 1.5 `toggle-idle` — Typo: `uswm-app` → `uwsm-app`

- **Severity**: ERROR
- **File**: `dotfiles/local/.local/bin/toggle-idle:12`
- **Issue**: `uswm-app -- hypridle` — missing the `w` in `uwsm`.
- **Fix**: Change to `uwsm-app -- hypridle`.

### 1.6 `take-screenshot` — Typo: `uswm-app` → `uwsm-app`

- **Severity**: ERROR
- **File**: `dotfiles/local/.local/bin/take-screenshot:8`
- **Issue**: `uswm-app -- flameshot` — missing the `w`.
- **Fix**: Change to `uwsm-app -- flameshot`.

### 1.7 `launch-walker` — Typo: `uswm-app` → `uwsm-app` (two instances)

- **Severity**: ERROR
- **File**: `dotfiles/local/.local/bin/launch-walker:8,22`
- **Issue**: Both `start_elephant()` and `start_walker_service()` use `uswm-app` instead of `uwsm-app`.
- **Fix**: Replace both occurrences with `uwsm-app`.

### 1.8 `launch-floating-terminal-with-presentation` — Undefined variable `$cmd`

- **Severity**: ERROR
- **File**: `dotfiles/local/.local/bin/launch-floating-terminal-with-presentation:10`
- **Issue**: `command="$*"` sets `$command`, but line 10 references `$cmd` (undefined). Also line 7 has `gum sping` instead of `gum spin`.
- **Fix**: Change `$cmd` to `$command` and `sping` to `spin`.

### 1.9 `hyprland-close-all-windows` — Typo: `xarg` → `xargs`

- **Severity**: ERROR
- **File**: `dotfiles/local/.local/bin/hyprland-close-all-windows:8`
- **Issue**: `xarg` is not a valid command.
- **Fix**: Change to `xargs` (the full `xargs` pipeline also needs fixing — `close_window` is a separate function that should use `xargs` directly).

### 1.10 `autostart.conf` — Typo: `systemclt` → `systemctl`

- **Severity**: ERROR
- **File**: `dotfiles/hyprland/.config/hypr/config/autostart.conf:13`
- **Issue**: `systemclt --user import-environment` — missing the `s`.
- **Fix**: Change to `systemctl --user import-environment`.

---

## 2. X11 Compatibility Issues in Wayland Environment

### 2.1 `uuidgen.sh` — Uses `xdotool` (X11)

- **Severity**: ERROR
- **File**: `dotfiles/local/.local/bin/uuidgen.sh:7`
- **Issue**: `xdotool type "$uuid"` fails on Wayland. Already handled in [spec 002](./002-uuidgen-script.md).
- **Fix**: Replace with `wtype "$uuid"`. Add `wtype` to `packages.base.txt`.

---

## 3. Dotfile Issues

### 3.1 VS Code directory — 389 files of runtime garbage

- **Severity**: WARNING
- **File**: `dotfiles/vs-code/.config/Code/` (entire directory)
- **Issue**: Contains 187+ log files, Chromium caches (LevelDB, vscdb), Session Storage, Local Storage, Crashpad, Cookies, GPUCache, Dawn caches, and other machine-specific runtime data. This bloats the repo (~hundreds of MB) and contains machine-specific state that should never be in a dotfile repo.
- **Fix**: Keep only `User/settings.json`, `User/keybindings.json`, and optionally `User/snippets/`. Add comprehensive VS Code ignore patterns to `.gitignore`:
  ```
  dotfiles/vs-code/.config/Code/Cache/
  dotfiles/vs-code/.config/Code/Cached*/
  dotfiles/vs-code/.config/Code/logs/
  dotfiles/vs-code/.config/Code/*.vscdb*
  dotfiles/vs-code/.config/Code/blob_storage/
  dotfiles/vs-code/.config/Code/Local Storage/
  dotfiles/vs-code/.config/Code/Session Storage/
  dotfiles/vs-code/.config/Code/GPUCache/
  dotfiles/vs-code/.config/Code/Dawn*/
  dotfiles/vs-code/.config/Code/Crashpad/
  dotfiles/vs-code/.config/Code/Backups/
  dotfiles/vs-code/.config/Code/Cookies*
  dotfiles/vs-code/.config/Code/DIPS*
  dotfiles/vs-code/.config/Code/Network*
  dotfiles/vs-code/.config/Code/code.lock
  dotfiles/vs-code/.config/Code/Preferences
  ```

### 3.2 `non-executable scripts` — Missing +x permission

- **Severity**: WARNING
- **Files**:
  - `dotfiles/local/.local/bin/env`
  - `dotfiles/local/.local/bin/env.fish`
  - `dotfiles/local/.local/bin/monitor-battery`
- **Issue**: Files have permissions `644` instead of `755`. They will not be executable after stow deployment (unless `dotfiles.sh` handles this — check `make_executable` logic).
- **Fix**: Run `chmod +x` on these files in the repo.

### 3.3 `env` and `env.fish` — Should these be executable?

- **Severity**: SUGGESTION
- **File**: `dotfiles/local/.local/bin/env`, `dotfiles/local/.local/bin/env.fish`
- **Issue**: These are PATH setup scripts. `env` is sourced by `.zshrc`, not executed directly. Making them executable is harmless but unnecessary.
- **Fix**: Confirm intent. If they should only be sourced, leave as-is (but then 3.2 doesn't apply to them).

### 3.4 Sway config files (dead code)

- **Severity**: WARNING
- **Directory**: `dotfiles/sway/`
- **Issue**: Contains legacy Sway config files (`appearance.conf`, `bar.conf`, `keybindings.conf`, `config.bakup`). The system uses Hyprland now. `config.bakup` is also tracked in git unnecessarily.
- **Fix**: Remove `dotfiles/sway/` entirely, or keep as reference but exclude from stowing and document.

### 3.5 SDDM and Plymouth stow packages commented out

- **Severity**: WARNING
- **Files**: `dotfiles/sddm/`, `dotfiles/plymouth/` exist in repo but are commented out in `dotfiles.sh`'s `SELECTED_CONFIG_PACKAGES`.
- **Issue**: Config directories exist but are not deployed. Either they should be deployed or removed.
- **Fix**: If they are active configs (e.g., SDDM is managed via the desktop module), remove the unused stow directories. If they should be stow-deployed, uncomment them.

---

## 4. Path Hardcoding Issues

### 4.1 `.zshrc` — Hardcoded `/home/dimanu/` path

- **Severity**: ERROR
- **File**: `dotfiles/zsh/.zshrc:6`
- **Issue**: `export PATH=/home/dimanu/.opencode/bin:$PATH` — will break for any other user.
- **Fix**: Change to `export PATH=$HOME/.opencode/bin:$PATH`.

### 4.2 `.gitconfig` — Hardcoded `/home/dimanu/` path

- **Severity**: WARNING
- **File**: `dotfiles/gitconfig/.gitconfig:8`
- **Issue**: `excludesfile = /home/dimanu/.gitignore` — hardcoded.
- **Fix**: Change to `excludesfile = ~/.gitignore`.

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

### 5.1 Missing `wtype` package

- **Severity**: ERROR
- **File**: `setup/config/packages.base.txt`
- **Issue**: `wtype` (Wayland keystroke injection, needed by `uuidgen.sh`) is not in the package list.
- **Fix**: Add `wtype` to `packages.base.txt`.

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

### 8.2 `.gitignore` is too minimal

- **Severity**: SUGGESTION
- **File**: `.gitignore`
- **Issue**: Missing patterns for:
  - VS Code runtime data (Cache, logs, databases, etc.)
  - `*.bakup` files (see `config.bakup`)
  - `.env` files
- **Fix**: Add comprehensive ignore patterns.

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

## Priority Order for Fixing

| Priority | Issue | Effort |
|----------|-------|--------|
| P0 | 1.1 `monitor-battery` syntax error (shell breaks) | 1 line |
| P0 | 1.5-1.7 `uswm-app` typos (3 scripts broken) | 1 min each |
| P0 | 1.8 `$cmd` undefined (script silently fails) | 1 line |
| P0 | 1.9 `xarg` typo (script silently fails) | 1 line |
| P0 | 1.10 `systemclt` typo (env import fails) | 1 line |
| P0 | 4.1 `.zshrc` hardcoded path (breaks for others) | 1 line |
| P1 | 1.2-1.3 Wrong timer/service names | 2 files |
| P1 | 1.4 Dead systemd service | 1 file |
| P1 | 2.1 `uuidgen.sh` X11 tool (Wayland fix) | Already spec'd |
| P1 | 5.1 Missing `wtype` package | 1 line |
| P1 | 4.2 `.gitconfig` hardcoded path | 1 line |
| P2 | 3.1 VS Code runtime garbage cleanup | 30 min |
| P2 | 3.5 Commented-out stow packages | 5 min |
| P2 | 6.1-6.5 Theme/config issues | Various |
| P2 | 7.1 `is_in_aur()` variable scoping | 2 lines |
| P3 | 8.1 Large binaries in git | 10 min |
| P3 | 8.2 `.gitignore` improvements | 10 min |
| P3 | 3.4 Sway dead code | 5 min |
| P4 | 9.1-9.7 Minor issues | Various |

---

## Verification

After fixing, run:
- `bash -n` on all `.sh` scripts to verify syntax
- `shellcheck` on all `.sh` scripts for best practices
- Verify Hyprland loads without errors: `hyprctl reload`
- Test each affected script manually
- `git status` to confirm no unintended files tracked
