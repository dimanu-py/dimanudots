.PHONY: help install

help:
	@echo "Available targets:"
	@echo "  install      - Install main packages using bash scripts"

install:
	@echo "Installing base packages..."
	@./setup/install/install-packages.sh --file setup/install/base_packages.txt
	@echo "Setting up yay AUR helper..."
	@./setup/install/setup-yay.sh
	@echo "Installing additional packages..."
	@./setup/install/install-packages.sh --file setup/install/packages.txt
	@echo "Installation completed successfully!"