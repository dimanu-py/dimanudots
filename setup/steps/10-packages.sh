#!/bin/bash

step_10_packages() {
    install_packages --file $DIMANUDOTS_SCRIPTS/config/packages.core.txt
    setup_yay
    install_packages --file $DIMANUDOTS_SCRIPTS/config/packages.base.txt
}