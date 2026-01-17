.PHONY: help bootstrap desktop development full check lint test

help:
	@echo "Available targets:"
	@echo "  bootstrap    - Bootstrap base system"
	@echo "  base         - Setup base packages and directories"
	@echo "  hardware     - Install hardware-related packages (bluetooth, audio, network)"
	@echo "  hyprland     - Setup Hyprland window manager and related packages"
	@echo "  display      - Configure display manager and themes"
	@echo "  dev          - Setup development environment (terminal, editors, tools)"
	@echo "  apps         - Install user applications (browsers, media players, etc.)"
	@echo "  full         - Complete setup"
	@echo "  check        - Run syntax checks"
	@echo "  lint         - Run ansible-lint"

bootstrap:
	ansible-playbook -i inventory/hosts main.yml --tags bootstrap --ask-become-pass

base:
	ansible-playbook -i inventory/hosts main.yml --tags base --ask-become-pass

hardware:
	ansible-playbook -i inventory/hosts main.yml --tags hardware --ask-become-pass

hyprland:
	ansible-playbook -i inventory/hosts main.yml --tags hyprland --ask-become-pass

display:
	ansible-playbook -i inventory/hosts main.yml --tags display --ask-become-pass

dev:
	ansible-playbook -i inventory/hosts main.yml --tags development --ask-become-pass

apps:
	ansible-playbook -i inventory/hosts main.yml --tags apps --ask-become-pass

full:
	$(MAKE) bootstrap
	$(MAKE) base
	$(MAKE) hardware
	$(MAKE) hyprland
	$(MAKE) display
	$(MAKE) dev
	$(MAKE) apps
	$(MAKE) development

check:
	ansible-playbook -i inventory/hosts main.yml --syntax-check

lint:
	ansible-lint