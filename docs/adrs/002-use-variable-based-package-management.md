# ADR-002: Use Variable-Based Package Management

## Status
Accepted

## Context
Original tasks had hardcoded package lists directly in YAML files. This makes modification difficult, prevents reusability, and lacks documentation for why each package is needed.

## Alternatives Considered
1. **Keep hardcoded packages**: Continue with current approach
   - Pro: Simple, no learning curve
   - Con: Hard to modify, not documented, not reusable

2. **External configuration files**: Use separate config files
   - Pro: Centralized configuration
   - Con: Additional file complexity

3. **Ansible variables in group_vars**: Use Ansible's built-in variable hierarchy
   - Pro: Follows Ansible best practices, proper precedence
   - Con: Learning curve for variable management

## Decision
Adopt variable-based package management using `inventory/group_vars/all.yml` with documented package lists including name and reason fields.

## Consequences
- **Positive**: Easy to modify packages without touching task logic
- **Positive**: Each package purpose is documented inline
- **Positive**: Variables can be reused across multiple tasks
- **Positive**: Follows Ansible variable precedence hierarchy
- **Negative**: Slight increase in complexity
- **Negative**: Requires understanding of Ansible variable system