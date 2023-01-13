#!/bin/bash
#

# ################################################################
# FORMATTING
# ################################################################

export ECHO_BOLD="\033[1m"
export ECHO_GREEN="\033[1;32m"
export ECHO_RED="\033[1;31m"
export ECHO_REPLACE="\033[1A\033[K"
export ECHO_RESET="\033[0m"

export NO_OUTPUT="/dev/null"

handle_errors() {
    echo -e "\n[ ${ECHO_RED}KO${ECHO_RESET} ] Script failed on line $1"
    exit 1
}

log_progress() {
    echo -e "[ .. ]\t$1"
}

log_success() {
    echo -e "${ECHO_REPLACE}[ ${ECHO_GREEN}OK${ECHO_RESET} ]\t$1"
}

# ################################################################
# ARGUMENT PARSING
# ################################################################

_arg_all="off"
_arg_system="off"
_arg_theme="off"

die() {
    local _ret="${2:-1}"
    test "${_PRINT_HELP:-no}" = yes && print_help >&2
    echo -e "[ ${ECHO_RED}KO${ECHO_RESET} ]\t$1" >&2
    exit "${_ret}"
}

begins_with_short_option() {
    local first_option all_short_options='asth'
    first_option="${1:0:1}"
    test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

parse_commandline() {
    while test $# -gt 0; do
        _key="$1"
        case "$_key" in
        -a | --no-all | --all)
            _arg_all="on"
            test "${1:0:5}" = "--no-" && _arg_all="off"
            ;;
        -a*)
            _arg_all="on"
            _next="${_key##-a}"
            if test -n "$_next" -a "$_next" != "$_key"; then
                { begins_with_short_option "$_next" && shift && set -- "-a" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
            fi
            ;;
        -s | --no-system | --system)
            _arg_system="on"
            test "${1:0:5}" = "--no-" && _arg_system="off"
            ;;
        -s*)
            _arg_system="on"
            _next="${_key##-s}"
            if test -n "$_next" -a "$_next" != "$_key"; then
                { begins_with_short_option "$_next" && shift && set -- "-s" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
            fi
            ;;
        -t | --no-theme | --theme)
            _arg_theme="on"
            test "${1:0:5}" = "--no-" && _arg_theme="off"
            ;;
        -t*)
            _arg_theme="on"
            _next="${_key##-t}"
            if test -n "$_next" -a "$_next" != "$_key"; then
                { begins_with_short_option "$_next" && shift && set -- "-t" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
            fi
            ;;
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
    printf '%s\n\n' "Fedora Workstation Personal Update Script"
    printf 'Usage: %s [-a|--all] [-s|--system] [-t|--theme] [-h|--help]\n' "$0"
    printf '\t%s\t\t%s\n' "-a, --all" "Updates everything (system and theme)"
    printf '\t%s\t\t%s\n' "-s, --system" "Updates only the system packages and applications"
    printf '\t%s\t\t%s\n' "-t, --theme" "Updates only the GNOME theme (shell, cursors, and icons)"
    printf '\t%s\t\t%s\n' "-h, --help" "Prints help"
}

# ################################################################
# BASE METHODS
# ################################################################

git_reset() {
    git clean -dx --force >$NO_OUTPUT 2>&1 || true
    git checkout . >$NO_OUTPUT 2>&1
    git fetch --all --prune --prune-tags --tags >$NO_OUTPUT 2>&1
    git remote prune origin >$NO_OUTPUT 2>&1
    git pull --rebase >$NO_OUTPUT 2>&1
    git gc --aggressive --prune=now >$NO_OUTPUT 2>&1
}

# ################################################################
# UPDATE METHODS
# ################################################################

00_update_system() {
    # ----------------------------------------------------------------
    # Updating and cleaning system applications
    # ----------------------------------------------------------------

    log_progress "Updating and cleaning system applications"

    sudo flatpak update --system --assumeyes >$NO_OUTPUT 2>&1
    sudo flatpak uninstall --system --assumeyes --unused >$NO_OUTPUT 2>&1

    log_success "Updating and cleaning system applications"

    # ----------------------------------------------------------------
    # Updating and cleaning user applications
    # ----------------------------------------------------------------

    log_progress "Updating and cleaning user applications"

    flatpak update --user --assumeyes >$NO_OUTPUT 2>&1
    flatpak uninstall --user --assumeyes --unused >$NO_OUTPUT 2>&1

    log_success "Updating and cleaning user applications"

    # ----------------------------------------------------------------
    # Updating and cleaning system packages
    # ----------------------------------------------------------------

    log_progress "Updating and cleaning system packages"

    sudo dnf clean all --quiet >$NO_OUTPUT 2>&1
    sudo dnf upgrade --allowerasing --assumeyes --best --quiet >$NO_OUTPUT 2>&1
    sudo dnf autoremove --allowerasing --assumeyes --best --quiet >$NO_OUTPUT 2>&1

    sudo dracut --force --parallel --regenerate-all >$NO_OUTPUT 2>&1

    log_success "Updating and cleaning system packages"

    # ----------------------------------------------------------------
    # Updating system drivers
    # ----------------------------------------------------------------

    log_progress "Updating system drivers"

    # The 'fwupdmgr' command exits with '1' (as failure) when no update is needed
    sudo fwupdmgr --assume-yes --force refresh >$NO_OUTPUT 2>&1 || true
    sudo fwupdmgr --assume-yes --force get-updates >$NO_OUTPUT 2>&1 || true

    log_success "Updating system drivers"
}

01_update_theme() {
    # ----------------------------------------------------------------
    # Configuring desktop settings
    # ----------------------------------------------------------------

    log_progress "Configuring desktop settings"

    gsettings set org.gnome.desktop.calendar show-weekdate true
    gsettings set org.gnome.desktop.interface clock-show-date true
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface enable-hot-corners true
    gsettings set org.gnome.desktop.interface font-antialiasing "rgba"
    gsettings set org.gnome.desktop.wm.preferences button-layout "close,minimize,maximize:appmenu"

    gsettings set org.gnome.mutter center-new-windows true

    gsettings set org.gnome.nautilus.preferences default-folder-viewer "list-view"
    gsettings set org.gnome.nautilus.preferences show-hidden-files true
    gsettings set org.gnome.nautilus.window-state sidebar-width 220

    gsettings set org.gtk.Settings.FileChooser show-hidden true

    log_success "Configuring desktop settings"

    # ----------------------------------------------------------------
    # Configuring desktop extensions
    # ----------------------------------------------------------------

    log_progress "Configuring desktop extensions"

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
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel brightness 1.0
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel customize true
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
    gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode "ALL_WINDOWS"
    gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style "DOTS"
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

    log_success "Configuring desktop extensions"

    # ----------------------------------------------------------------
    # Configuring desktop fonts
    # ----------------------------------------------------------------

    log_progress "Configuring desktop fonts"

    gsettings set org.gnome.desktop.interface document-font-name "Roboto 11"
    gsettings set org.gnome.desktop.interface font-name "Roboto 11"
    gsettings set org.gnome.desktop.interface monospace-font-name "Roboto Mono 11"
    gsettings set org.gnome.desktop.wm.preferences titlebar-font "Roboto 11"

    sudo fc-cache --really-force

    log_success "Configuring desktop fonts"

    # ----------------------------------------------------------------
    # Updating shell theme
    # ----------------------------------------------------------------

    log_progress "Updating shell theme"

    cd ~/.setup/shell/Colloid
    git_reset

    sudo ./install.sh \
        --color dark \
        --libadwaita \
        --theme default \
        --tweaks rimless >$NO_OUTPUT 2>&1

    gsettings set org.gnome.desktop.interface gtk-theme "Colloid-Dark"
    gsettings set org.gnome.shell.extensions.user-theme name "Colloid-Dark"

    log_success "Updating shell theme"

    # ----------------------------------------------------------------
    # Updating icon theme
    # ----------------------------------------------------------------

    log_progress "Updating icon theme"

    cd ~/.setup/icons/Colloid
    git_reset

    sudo ./install.sh \
        --scheme default \
        --theme default >$NO_OUTPUT 2>&1

    gsettings set org.gnome.desktop.interface icon-theme "Colloid-dark"

    log_success "Updating icon theme"

    # ----------------------------------------------------------------
    # Updating cursor theme
    # ----------------------------------------------------------------

    log_progress "Updating cursor theme"

    cd ~/.setup/cursors/Colloid/cursors
    git_reset

    sudo ./install.sh >$NO_OUTPUT 2>&1

    gsettings set org.gnome.desktop.interface cursor-theme "Colloid-cursors"

    log_success "Updating cursor theme"
}

# ################################################################
# MAIN
# ################################################################

parse_commandline "$@"

trap 'handle_errors $LINENO' ERR
sudo echo ""

neofetch

if [ ${_arg_all} = "on" ]; then
    _arg_system="on"
    _arg_theme="on"
fi

if [ ${_arg_system} = "on" ]; then
    00_update_system
fi

if [ ${_arg_theme} = "on" ]; then
    01_update_theme
fi

if [ ${_arg_system} = "off" ] && [ ${_arg_theme} = "off" ]; then
    print_help
fi

echo -e "\n[ ${ECHO_BOLD}OK${ECHO_RESET} ]"
