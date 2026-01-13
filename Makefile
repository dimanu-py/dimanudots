.PHONY: help bootstrap desktop development full check lint test

help:
	@echo "Available targets:"
	@echo "  bootstrap    - Bootstrap base system"
	@echo "  desktop      - Setup desktop environment"
	@echo "  development  - Install development tools"
	@echo "  full         - Complete setup (bootstrap + desktop + dev)"
	@echo "  check        - Run syntax checks"
	@echo "  lint         - Run ansible-lint"
	@echo "  test         - Run playbook in check mode"

bootstrap:
	ansible-playbook -i inventory/hosts playbooks/bootstrap.yml --ask-become-pass

desktop:
	ansible-playbook -i inventory/hosts playbooks/desktop.yml --ask-become-pass

development:
	ansible-playbook -i inventory/hosts playbooks/development.yml --ask-become-pass

full:
	$(MAKE) bootstrap
	$(MAKE) desktop
	$(MAKE) development

check:
	ansible-playbook -i inventory/hosts playbooks/site.yml --syntax-check

lint:
	ansible-lint

test:
	ansible-playbook -i inventory/hosts playbooks/site.yml --check