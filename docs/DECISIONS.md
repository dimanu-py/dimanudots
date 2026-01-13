# Architecture Decision Records (ADRs)

This document records important architectural decisions made during the development of this Arch Linux + Hyprland desktop automation project.

## ADR Format
- **Status**: Status of the decision (Proposed, Accepted, Deprecated, Superseded)
- **Context**: The problem or situation requiring a decision
- **Decision**: The chosen solution
- **Consequences**: Results, trade-offs, and implications of the decision

---

## ADR-001: Use Ansible Collections for AUR Support

### Status
Accepted

### Context
Ansible core provides basic modules but lacks support for Arch Linux AUR (Arch User Repository) packages. The existing automation setup uses `community.general.yay` module extensively for installing AUR packages. Without proper collections, these tasks would fail with "module not found" errors.

### Alternatives Considered
1. **Use shell commands for AUR**: Replace `community.general.yay` with raw shell/yay commands
   - Pro: No collection dependency
   - Con: Loses idempotency, error handling, and Ansible benefits

2. **Skip AUR automation**: Only use official pacman repositories
   - Pro: Simpler, no external dependencies
   - Con: Cannot access large AUR ecosystem (hyprland, yay itself, etc.)

3. **Install Ansible collections**: Use community.general for AUR and extended functionality
   - Pro: Maintains idempotency, provides essential AUR support
   - Con: Requires internet for initial installation, collection maintenance overhead

### Decision
Install Ansible collections with specific focus on `community.general` which provides the `yay` module. Also include `ansible.posix` for system operations and `community.crypto` for future security needs.

### Consequences
- **Positive**: Enables AUR automation while maintaining Ansible benefits (idempotency, error handling)
- **Positive**: Provides extended functionality beyond core Ansible modules
- **Positive**: Follows existing codebase patterns
- **Negative**: Requires internet connection for initial setup
- **Negative**: Adds collection maintenance overhead
- **Negative**: External dependency that may version-conflict with Ansible core

---

## ADR-002: Variable-Based Package Management

### Status
Accepted

### Context
Original tasks had hardcoded package lists directly in YAML files. This makes modification difficult, prevents reusability, and lacks documentation for why each package is needed.

### Alternatives Considered
1. **Keep hardcoded packages**: Continue with current approach
   - Pro: Simple, no learning curve
   - Con: Hard to modify, not documented, not reusable

2. **External configuration files**: Use separate config files
   - Pro: Centralized configuration
   - Con: Additional file complexity

3. **Ansible variables in group_vars**: Use Ansible's built-in variable hierarchy
   - Pro: Follows Ansible best practices, proper precedence
   - Con: Learning curve for variable management

### Decision
Adopt variable-based package management using `inventory/group_vars/all.yml` with documented package lists including name and reason fields.

### Consequences
- **Positive**: Easy to modify packages without touching task logic
- **Positive**: Each package purpose is documented inline
- **Positive**: Variables can be reused across multiple tasks
- **Positive**: Follows Ansible variable precedence hierarchy
- **Negative**: Slight increase in complexity
- **Negative**: Requires understanding of Ansible variable system

---

## ADR-003: Idempotent Yay Installation Pattern

### Status
Accepted

### Context
Yay must be installed for AUR package management, but should not be rebuilt if already present. Multiple execution of bootstrap phase should not break existing installation.

### Alternatives Considered
1. **Always reinstall**: Remove and reinstall yay each time
   - Pro: Guarantees latest version
   - Con: Wasteful, breaks existing configurations

2. **Check and skip installation**: Pre-check for yay existence
   - Pro: Efficient, safe for repeated runs
   - Con: Requires robust checking logic

3. **Force flag approach**: Use --force parameter to handle idempotency
   - Pro: Simple implementation
   - Con: May mask actual installation issues

### Decision
Implement full idempotency pattern: check for existing yay, skip if present, otherwise install with proper AUR build practices and cleanup.

### Consequences
- **Positive**: Safe to re-run bootstrap multiple times
- **Positive**: Efficient - no unnecessary rebuilds
- **Positive**: Follows AUR best practices (user builds, temp dirs)
- **Positive**: Clean build process with artifact cleanup
- **Negative**: More complex than simple installation
- **Negative**: Requires careful condition management

---

## ADR-004: Use Custom Implementation Instead of External Galaxy Roles

### Status
Accepted

### Context
The existing `requirements.yml` contains external Galaxy roles (geerlingguy.git, geerlingguy.pip) alongside collections. However, the project already has custom implementations for git, development tools, and package management in the `tasks/` directory. Installing external roles would create conflicts with existing custom logic.

### Alternatives Considered
1. **Keep external roles**: Use geerlingguy.git and geerlingguy.pip from Galaxy
   - Pro: Pre-built, tested, maintained by community
   - Con: Conflicts with existing custom tasks, generic not tailored
   - Con: Different patterns than project's custom implementation

2. **Remove external roles**: Use only custom implementation in `tasks/`
   - Pro: Consistent with existing codebase patterns
   - Pro: Tailored to specific project needs
   - Pro: No external dependencies beyond collections
   - Con: Custom code requires maintenance

3. **Hybrid approach**: Mix external roles for some tasks, custom for others
   - Pro: Leverages community expertise where beneficial
   - Con: Inconsistent patterns, maintenance complexity

### Decision
Remove all external roles from `requirements.yml` and keep only the collections section. Use custom implementation exclusively for all automation tasks.

### Consequences
- **Positive**: Consistent codebase with unified patterns
- **Positive**: Tailored to specific Arch Linux + Hyprland needs
- **Positive**: No external role dependencies to maintain
- **Positive**: No conflicts between custom and external logic
- **Negative**: Custom code requires project maintenance
- **Negative**: Loses community expertise for generic tasks

---