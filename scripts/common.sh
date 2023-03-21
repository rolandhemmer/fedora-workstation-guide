#!/bin/bash

# ################################################################
# Formatting
# ################################################################

OUTPUT_BOLD="tput bold"
OUTPUT_EMPTY="/dev/null"
OUTPUT_ERROR="tput setaf 1"
OUTPUT_RESET="tput sgr0"
OUTPUT_SUCCESS="tput setaf 2"
OUTPUT_WARNING="tput setaf 3"

handle_errors() {
    echo -e "\n$($OUTPUT_ERROR)Error:$($OUTPUT_RESET) command '$2' failed (line $1)"
    exit 1
}

log_step() {
    echo "-- $1"
}

log_success() {
    echo -e "\n$($OUTPUT_SUCCESS)Done!$($OUTPUT_RESET)"
}

# ################################################################
# Base Methods
# ################################################################

ask_reboot() {
    while true; do
        echo -e "\nA reboot is required to continue. Do you wish to reboot now? [Y/N]"
        read yn
        case $yn in
        [Yy]*)
            sudo reboot now
            break
            ;;
        [Nn]*) exit ;;
        *) echo "Please answer yes or no." ;;
        esac
    done
}

dnf_group_install() {
    sudo dnf group install --assumeyes --quiet $@ >$OUTPUT_EMPTY 2>&1
}

dnf_group_update() {
    sudo dnf group update --assumeyes --quiet $@ >$OUTPUT_EMPTY 2>&1
}

dnf_package_install() {
    sudo dnf install --assumeyes --quiet $@ >$OUTPUT_EMPTY 2>&1
}

dnf_package_remove() {
    sudo dnf remove --assumeyes --quiet $@ >$OUTPUT_EMPTY 2>&1
}

flatpak_install() {
    flatpak install --assumeyes --user flathub $@ >$OUTPUT_EMPTY 2>&1
}
