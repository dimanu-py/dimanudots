# 001 - Dynamic Monitor Auto-Detection on Dock

**Status**: Pending  
**Priority**: High  
**Created**: 2026-06-13  

---

## Description

When the laptop is connected to a dock station, two external monitors appear as independent outputs (e.g., `DP-1`, `DP-2`). Currently, the system uses a static `monitor=,preferred,auto,auto` config, which does not adapt to dock state.

The goal is to automatically detect dock connection/disconnection and reconfigure monitors accordingly:

- **Docked**: detect both external monitors, set the first detected as primary, the second as extension, and disable the laptop's internal display (`eDP-1`).
- **Undocked**: re-enable the laptop's internal display and restore the previous layout.

When a single external monitor is connected without the dock, it should extend the laptop display (both active).

---

## Decisions

| Question | Decision |
|----------|----------|
| Which monitor is primary? | First detected external by connection order |
| Dock connection type | Two independent outputs (DP-1, DP-2) |
| Single external (no dock) | Extend laptop display |
| Trigger mechanism | **Event-driven (udev rule)** — polling kept as fallback if udev proves unreliable |
| After undock position | Restore previous layout |
| Workspace distribution | **TBD** — see [Workspace Distribution](#workspace-distribution) |
| Manual re-detect binding | `SUPER + SHIFT + D` (D for **D**etect) |

---

## Acceptance Criteria

- [ ] A script `~/.local/bin/dynamic-monitors.sh` is created
- [ ] A udev rule triggers the script on dock connect/disconnect events
- [ ] A keyboard binding `SUPER + SHIFT + D` forces manual re-detection
- [ ] When the dock is connected, both external monitors are detected and configured:
  - First external becomes primary display
  - Second external is set as extension to the right of primary
  - Laptop display (`eDP-1`) is disabled
- [ ] When the dock is disconnected, the laptop display is re-enabled and centered
- [ ] When a single external monitor is connected (no dock), it extends the laptop display (both active)
- [ ] Monitor layout state (position, order) is persisted and restored on undock
- [ ] The detection runs promptly (not delayed more than 2-3 seconds)
- [ ] The script is idempotent: no redundant `hyprctl` calls if state hasn't changed

---

## Implementation Notes

### Trigger Mechanism: Event-Driven (Primary) + Polling (Fallback)

#### Primary: udev Rule

A udev rule will detect dock connection/disconnection by matching on the dock's USB vendor/product ID or by watching DRM events. The rule runs a script that checks if the current user is logged in and then executes the monitor reconfiguration.

```
# /etc/udev/rules.d/99-dock-monitor.rules
# When dock connects or disconnects, trigger monitor reconfiguration
ACTION=="change", SUBSYSTEM=="drm", ENV{DISPLAY}==NULL, \
    RUN+="/usr/local/bin/dynamic-monitors-trigger.sh"
```

The trigger script (`dynamic-monitors-trigger.sh`) will:
1. Determine the active user session
2. Run `dynamic-monitors.sh` as that user via `su`/`sudo`
3. Log results for debugging

#### Fallback: Polling

If the udev approach proves unreliable (e.g., dock doesn't emit distinguishable udev events, or timing issues), fall back to an `exec-once` background script that polls `hyprctl monitors` every 2-3 seconds.

#### Both Approaches Share the Core Logic

The core monitor reconfiguration logic lives in `dynamic-monitors.sh` and is identical regardless of trigger mechanism.

### Script Design

```bash
# ~/.local/bin/dynamic-monitors.sh
# Triggered by: udev rule OR exec-once polling OR manual keybind

# Pseudo-logic:
# - Query hyprctl monitors to current state
# - Compare with previous state (saved to state file)
# - If state changed:
#   - Docked (3 monitors total, 2 external): disable eDP-1, configure externals
#   - Undocked (only eDP-1): re-enable eDP-1, restore position
#   - Single external (2 monitors): extend layout
# - Write new state to state file
# - Monitor names and positions determined at runtime
```

### Hyprland Integration

- Add keybinding in `system.conf` or `tiling_management.conf`:
  ```
  bindd = $mainMod $shift, D, Re-detect monitors, exec, $scripts/dynamic-monitors.sh
  ```
- If fallback polling is needed, add to `autostart.conf`:
  ```
  exec-once = $scripts/dynamic-monitors.sh --watch
  ```

### State Persistence

- Save monitor layout state to `~/.config/hypr/monitor-state.json`
- Format:
  ```json
  {
    "last_layout": "docked",
    "eDP-1": { "enabled": false, "position": "0x0" },
    "externals": [
      { "name": "DP-1", "primary": true, "position": "0x0" },
      { "name": "DP-2", "primary": false, "position": "1920x0" }
    ]
  }
  ```

### Dependencies

- `hyprctl` (from `hyprland` package)
- Standard POSIX tools (no extra dependencies)
- For udev approach: `udev`, `sudo`/`su`
- For polling fallback: `sleep`, basic shell (`wait` not needed)

---

## Workspace Distribution

**⚠️ DECISION PENDING** — How should workspaces be distributed across the two external monitors when docked?

This needs to be decided and documented before final implementation.

### Options to Consider

- **Option A — Dedicated workspaces**: Primary monitor gets workspaces 1-5, extension gets workspaces 6-10
- **Option B — Per-monitor workspaces**: Each monitor has its own set (e.g., workspace 1 on both monitors, workspace 2 on both, etc.)
- **Option C — Keep current workspace where it is**: Move focused workspace between monitors as needed (no automatic assignment)
- **Option D — Follows behavior from undocked state**: Workspaces stay where they were, but the visible workspace on each monitor is adjusted

### What This Affects

- The `dynamic-monitors.sh` script may need to move specific workspaces to specific monitors
- The Hyprland config may need `workspace = 1, monitor:DP-1` rules in `monitor.conf`
- Theme or custom rules may need adjustment

---

## Questions for Future

- Should we add a `GDK_SCALE` override per-monitor for mixed DPI setups?
- Should the event-driven approach use `udev` directly or `acpid` / `systemd-logind` for better Wayland integration?
- Add a notification (via `swaync`) when monitor layout changes so the user knows detection happened
