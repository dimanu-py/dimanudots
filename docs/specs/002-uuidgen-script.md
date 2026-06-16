# 002 - UUID Generation Script with Keybinding

**Status**: Pending  
**Priority**: Medium  
**Created**: 2026-06-13  

---

## Description

Create (or rewrite) a script `uuidgen.sh` that generates a UUID, copies it to the system clipboard, and types it at the current cursor position. Assign it to a Hyprland keybinding for quick access.

The current script at `dotfiles/local/.local/bin/uuidgen.sh` uses `xdotool type` (X11 tool) which does not work under Wayland/Hyprland. It needs to be updated to use `wtype` (Wayland-native keystroke injection).

---

## Decisions

| Question | Decision |
|----------|----------|
| Wayland typing tool | `wtype` (from community repo) |
| Keybinding | `SUPER + U` |
| UUID versions | v4 by default, `-v7` flag for v7 |
| Clipboard tool | `wl-copy` (already in use, from `wl-clipboard`) |

---

## Acceptance Criteria

- [ ] Script at `~/.local/bin/uuidgen.sh` works under Wayland/Hyprland
- [ ] Running `uuidgen.sh` without arguments: generates UUID v4, copies to clipboard, types it at cursor
- [ ] Running `uuidgen.sh -v7`: generates UUID v7, copies to clipboard, types it at cursor
- [ ] Running `uuidgen.sh -h` or `--help`: shows usage
- [ ] A keybinding is added in Hyprland config:
  ```
  bindd = $mainMod, U, Generate UUID, exec, $scripts/uuidgen.sh
  ```
- [ ] The script correctly detects which tool to use for each operation (`wl-copy` must be installed, `wtype` must be installed)
- [ ] Error handling: graceful message if `wtype` or `wl-copy` is missing

---

## Implementation Notes

### Usage

```bash
uuidgen.sh              # Generate UUID v4, copy + type
uuidgen.sh -v7          # Generate UUID v7, copy + type
uuidgen.sh -h           # Show help
```

### Script Structure

```bash
#!/bin/bash

# Generate UUID
# - default: v4 (random)
# - -v7: v7 (time-ordered)

# Validate dependencies:
# - wl-copy (wl-clipboard)
# - wtype

# Copy to clipboard: echo -n "$uuid" | wl-copy
# Type at cursor: wtype "$uuid"
```

### Wayland Compatibility

| Function | X11 (old) | Wayland (new) |
|----------|-----------|---------------|
| Clipboard | `xclip` / `xsel` | `wl-copy` |
| Type text | `xdotool type` | `wtype` |

### UUID v7 Generation

UUID v7 is time-ordered (timestamp-prefixed random). Can be generated via:
- `uuidgen --v7` (if supported by util-linux)
- Custom implementation via `/dev/urandom` + `date +%s` encoding
- Python one-liner: `python3 -c "import uuid; print(uuid.uuid7())"` (Python 3.14+)

### Hyprland Config Changes

- Update `dotfiles/hyprland/.config/hypr/config/bindings/applications.conf`:
  ```
  bindd = $mainMod, U, Generate UUID, exec, $scripts/uuidgen.sh
  ```

### Dependencies

- `wl-clipboard` (already in `packages.base.txt`)
- `wtype` (needs to be added to `packages.base.txt`)

---

## Questions for Future

- Should the script also accept piping (e.g., `echo "something" | uuidgen.sh` to copy and type arbitrary text)?
- Should there be a notification (via `swaync`) confirming the UUID was generated and copied?
