# ADR-001: Use Ansible Collections for AUR Support

## Status
Accepted

## Context
Ansible core provides basic modules but lacks support for Arch Linux AUR (Arch User Repository) packages. The existing automation setup uses `community.general.yay` module extensively for installing AUR packages. Without proper collections, these tasks would fail with "module not found" errors.

## Alternatives Considered
1. **Use shell commands for AUR**: Replace `community.general.yay` with raw shell/yay commands
   - Pro: No collection dependency
   - Con: Loses idempotency, error handling, and Ansible benefits

2. **Skip AUR automation**: Only use official pacman repositories
   - Pro: Simpler, no external dependencies
   - Con: Cannot access large AUR ecosystem (hyprland, yay itself, etc.)

3. **Install Ansible collections**: Use community.general for AUR and extended functionality
   - Pro: Maintains idempotency, provides essential AUR support
   - Con: Requires internet for initial installation, collection maintenance overhead

## Decision
Install Ansible collections with specific focus on `community.general` which provides `yay` module. Also include `ansible.posix` for system operations and `community.crypto` for future security needs.

## Consequences
- **Positive**: Enables AUR automation while maintaining Ansible benefits (idempotency, error handling)
- **Positive**: Provides extended functionality beyond core Ansible modules
- **Positive**: Follows existing codebase patterns
- **Negative**: Requires internet connection for initial setup
- **Negative**: Adds collection maintenance overhead
- **Negative**: External dependency that may version-conflict with Ansible core