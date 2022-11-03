#!/bin/bash

export ECHO_BOLD="\033[1m"
export ECHO_GREEN="\033[1;32m"
export ECHO_GREY="\033[0;37m"
export ECHO_RED="\033[1;31m"
export ECHO_RESET="\033[0m"
export ECHO_REPLACE="\033[1A\033[K"

export NO_OUTPUT="/dev/null"

__install_dnf__() {
    sudo dnf install --assumeyes --quiet $1 >$NO_OUTPUT 2>&1
}

__install_flatpak__() {
    flatpak install --assumeyes --user flathub $1 >$NO_OUTPUT 2>&1
}

__log_progress__() {
    echo -e "[ .. ]\t$1"
}

__log_success__() {
    echo -e "${ECHO_REPLACE}[ ${ECHO_GREEN}OK${ECHO_RESET} ]\t$1"
}

__log_success_alt__() {
    echo -e "[ ${ECHO_GREEN}OK${ECHO_RESET} ]\t$1"
}

__log_title__() {
    echo -e "${ECHO_BOLD}$1${ECHO_RESET}"
}
