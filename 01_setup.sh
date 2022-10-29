#!/bin/bash
#
# Generated using Argbash v2.9.0
# See https://argbash.io for more
#

# --------------------------------
# Arguments Parsing and Management
# --------------------------------

begins_with_short_option() {
    local first_option all_short_options='h'
    first_option="${1:0:1}"
    test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

die() {
    local _ret="${2:-1}"
    test "${_PRINT_HELP:-no}" = yes && print_help >&2
    echo -e "[ ${ECHO_RED}KO${ECHO_RESET} ]\t$1" >&2
    exit "${_ret}"
}

parse_commandline() {
    while test $# -gt 0; do
        _key="$1"
        case "$_key" in
        -h | --help)
            print_help
            exit 0
            ;;
        -h*)
            print_help
            exit 0
            ;;
        *)
            _PRINT_HELP=yes die "Unexpected argument '$1'" 1
            ;;
        esac
        shift
    done
}

print_help() {
    printf '%s\n\n' "Fedora Workstation Personal Installation Script (2/2)"
    printf 'Usage: %s [-h|--help]\n' "$0"
    printf '\t%s\t\t%s\n' "-h, --help" "Prints help"
    printf '\n'
}

# --------------------------------
# Functions
# --------------------------------

__install_dnf__() {
    sudo dnf install --assumeyes --quiet $1 >$NO_OUTPUT
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

00_configure_desktop_extensions() {
    __log_title__ "\n==> Configuring desktop extensions"

    # ################################################################
    # Enabling desktop extensions
    # ################################################################

    __log_progress__ "Enabling desktop extensions"

    gnome-extensions disable background-logo@fedorahosted.org

    gnome-extensions enable AlphabeticalAppGrid@stuarthayhurst
    gnome-extensions enable blur-my-shell@aunetx
    gnome-extensions enable dash-to-dock@micxgx.gmail.com
    gnome-extensions enable hidetopbar@mathieu.bidon.ca
    gnome-extensions enable trayIconsReloaded@selfmade.pl
    gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com

    __log_success__ "Enabling desktop extensions"

    # ################################################################
    # Configuring desktop extensions
    # ################################################################

    __log_progress__ "Configuring desktop extensions"

    gsettings set org.gnome.shell.extensions.alphabetical-app-grid folder-order-position "alphabetical"
    gsettings set org.gnome.shell.extensions.alphabetical-app-grid logging-enabled false
    gsettings set org.gnome.shell.extensions.alphabetical-app-grid sort-folder-contents true

    gsettings set org.gnome.shell.extensions.blur-my-shell brightness 1.0
    gsettings set org.gnome.shell.extensions.blur-my-shell color-and-noise false
    gsettings set org.gnome.shell.extensions.blur-my-shell hacks-level 1
    gsettings set org.gnome.shell.extensions.blur-my-shell sigma 200
    gsettings set org.gnome.shell.extensions.blur-my-shell.appfolder customize false
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications blur false
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications blur-on-overview false
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications customize false
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications enable-all false
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications opacity 255
    gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur false
    gsettings set org.gnome.shell.extensions.blur-my-shell.hidetopbar compatibility false
    gsettings set org.gnome.shell.extensions.blur-my-shell.overview style-components 0
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel customize true
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel brightness 1.0
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel override-background-dynamically true
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel sigma 0
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel unblur-in-overview true
    gsettings set org.gnome.shell.extensions.blur-my-shell.screenshot blur false

    gsettings set org.gnome.shell.extensions.dash-to-dock apply-custom-theme false
    gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.0
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action "minimize"
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color false
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-customize-running-dots true
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-border-color 'rgb(36,36,36)'
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 42
    gsettings set org.gnome.shell.extensions.dash-to-dock disable-overview-on-startup true
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    gsettings set org.gnome.shell.extensions.dash-to-dock height-fraction 1.0
    gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode "MAXIMIZED_WINDOWS"
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-only-mounted false
    gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode "FIXED"

    gsettings set org.gnome.shell.extensions.hidetopbar enable-active-window true
    gsettings set org.gnome.shell.extensions.hidetopbar enable-intellihide true
    gsettings set org.gnome.shell.extensions.hidetopbar hot-corner true
    gsettings set org.gnome.shell.extensions.hidetopbar keep-round-corners true
    gsettings set org.gnome.shell.extensions.hidetopbar mouse-sensitive false
    gsettings set org.gnome.shell.extensions.hidetopbar mouse-sensitive-fullscreen-window false
    gsettings set org.gnome.shell.extensions.hidetopbar mouse-triggers-overview true
    gsettings set org.gnome.shell.extensions.hidetopbar show-in-overview true

    gsettings set org.gnome.shell.extensions.trayIconsReloaded icons-limit 5

    __log_success__ "Configuring desktop extensions"
}

01_configure_desktop_theme() {
    __log_title__ "\n==> Configuring desktop theme"

    # ################################################################
    # Applying theme to legacy applications
    # ################################################################

    __log_progress__ "Applying theme to legacy applications"

    gsettings set org.gnome.shell.extensions.user-theme name "Colloid-Dark"

    __log_success__ "Applying theme to legacy applications"

    # ################################################################
    # Applying theme to sandboxed applications
    # ################################################################

    __log_progress__ "Applying theme to sandboxed applications"

    __install_dnf__ \
        libappstream-glib \
        ostree

    wget --quiet "https://raw.githubusercontent.com/refi64/stylepak/master/stylepak"
    chmod +x stylepak
    sudo mv stylepak /usr/bin/

    stylepak install-user >$NO_OUTPUT

    __log_success__ "Applying theme to sandboxed applications"
}

# --------------------------------
# Main
# --------------------------------

export ECHO_BOLD="\033[1m"
export ECHO_GREEN="\033[1;32m"
export ECHO_GREY="\033[0;37m"
export ECHO_RED="\033[1;31m"
export ECHO_RESET="\033[0m"
export ECHO_REPLACE="\033[1A\033[K"

export NO_OUTPUT="/dev/null"

parse_commandline "$@"

set -e
sudo echo ""

cat <<"EOT"
    ________________  ____  ____  ___       _____ ______________  ______
   / ____/ ____/ __ \/ __ \/ __ \/   |     / ___// ____/_  __/ / / / __ \
  / /_  / __/ / / / / / / / /_/ / /| |     \__ \/ __/   / / / / / / /_/ /
 / __/ / /___/ /_/ / /_/ / _, _/ ___ |    ___/ / /___  / / / /_/ / ____/
/_/   /_____/_____/\____/_/ |_/_/  |_|   /____/_____/ /_/  \____/_/

EOT

00_configure_desktop_extensions
01_configure_desktop_theme

echo -e "\n[ ${ECHO_BOLD}OK${ECHO_RESET} ]"
