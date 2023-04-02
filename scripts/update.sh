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
# Argument Parsing
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
    printf '%s\n\n' "Fedora Workstation Update Script"
    printf 'Usage: %s [-a|--all] [-s|--system] [-t|--theme] [-h|--help]\n' "$0"
    printf '\t%s\t\t%s\n' "-a, --all" "Updates everything (system and theme)"
    printf '\t%s\t\t%s\n' "-s, --system" "Updates only the system packages and applications"
    printf '\t%s\t\t%s\n' "-t, --theme" "Updates only the GNOME theme (shell, cursors, and icons)"
    printf '\t%s\t\t%s\n' "-h, --help" "Prints help"
}

# ################################################################
# Update Methods
# ################################################################

00_update_system() {
    # ----------------------------------------------------------------

    # Configuring privacy settings
    log_step "Configuring privacy settings"

    gsettings set org.gnome.desktop.privacy report-technical-problems false

    sudo systemctl disable \
        abrt-journal-core \
        abrt-oops \
        abrt-xorg \
        abrtd >$OUTPUT_EMPTY 2>&1

    # ----------------------------------------------------------------

    # Updating and cleaning system packages
    log_step "Updating and cleaning system packages"

    sudo dnf clean all --quiet >$OUTPUT_EMPTY 2>&1
    sudo dnf upgrade --assumeyes --quiet >$OUTPUT_EMPTY 2>&1
    sudo dnf autoremove --assumeyes --quiet >$OUTPUT_EMPTY 2>&1

    sudo akmods --force >$OUTPUT_EMPTY 2>&1
    sudo dracut --force >$OUTPUT_EMPTY 2>&1

    sudo journalctl --rotate >$OUTPUT_EMPTY 2>&1
    sudo journalctl --vacuum-time=1s >$OUTPUT_EMPTY 2>&1

    sudo fc-cache --really-force

    # ----------------------------------------------------------------

    # Updating system drivers
    log_step "Updating system drivers"

    sudo fwupdmgr --assume-yes --force refresh >$OUTPUT_EMPTY 2>&1 || true
    sudo fwupdmgr --assume-yes --force get-updates >$OUTPUT_EMPTY 2>&1 || true

    # ----------------------------------------------------------------

    # Updating and cleaning system applications
    log_step "Updating and cleaning system applications"

    sudo flatpak update --system --assumeyes >$OUTPUT_EMPTY 2>&1
    sudo flatpak uninstall --system --assumeyes --unused >$OUTPUT_EMPTY 2>&1

    # ----------------------------------------------------------------

    # Updating and cleaning user applications
    log_step "Updating and cleaning user applications"

    flatpak update --user --assumeyes >$OUTPUT_EMPTY 2>&1
    flatpak uninstall --user --assumeyes --unused >$OUTPUT_EMPTY 2>&1

}

01_update_theme() {
    # ----------------------------------------------------------------

    # Configuring GNOME desktop settings
    log_step "Configuring GNOME desktop settings"

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

    gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden true
    gsettings set org.gtk.Settings.FileChooser show-hidden true

    # ----------------------------------------------------------------

    # Configuring GNOME desktop extensions
    log_step "Configuring GNOME desktop extensions"

    cd /usr/share/glib-2.0/schemas

    sudo wget \
        --output-document="org.gnome.shell.extensions.dash-to-dock.gschema.xml" \
        --quiet \
        "https://raw.githubusercontent.com/micheleg/dash-to-dock/master/schemas/org.gnome.shell.extensions.dash-to-dock.gschema.xml"

    sudo wget \
        --output-document="org.gnome.shell.extensions.user-theme.gschema.xml" \
        --quiet \
        "https://gitlab.gnome.org/GNOME/gnome-shell-extensions/-/raw/main/extensions/user-theme/org.gnome.shell.extensions.user-theme.gschema.xml"

    sudo wget \
        --output-document="org.gnome.shell.extensions.AlphabeticalAppGrid.gschema.xml" \
        --quiet \
        "https://raw.githubusercontent.com/stuarthayhurst/alphabetical-grid-extension/master/extension/schemas/org.gnome.shell.extensions.AlphabeticalAppGrid.gschema.xml"

    sudo glib-compile-schemas . >$OUTPUT_EMPTY 2>&1

    gsettings set org.gnome.shell.extensions.alphabetical-app-grid folder-order-position "start"
    gsettings set org.gnome.shell.extensions.alphabetical-app-grid logging-enabled false
    gsettings set org.gnome.shell.extensions.alphabetical-app-grid sort-folder-contents true

    gsettings set org.gnome.shell.extensions.dash-to-dock apply-custom-theme false
    gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(34,34,34)'
    gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 1.0
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action "minimize"
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color true
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-customize-running-dots true
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-border-color 'rgb(34,34,34)'
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-color 'rgb(255,255,255)'
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 36
    gsettings set org.gnome.shell.extensions.dash-to-dock disable-overview-on-startup true
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true
    gsettings set org.gnome.shell.extensions.dash-to-dock height-fraction 1.0
    gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style "DOTS"
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-only-mounted false
    gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode "FIXED"

    gsettings set org.gnome.shell.extensions.user-theme name "Yaru-blue-dark"
    # ----------------------------------------------------------------

    # Updating GNOME shell theme
    log_step "Updating GNOME shell theme"

    gsettings set org.gnome.desktop.interface cursor-theme "Yaru"
    gsettings set org.gnome.desktop.interface gtk-theme "Yaru-blue-dark"
    gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue-dark"
    gsettings set org.gnome.desktop.sound theme-name "Yaru"

    if [[ ! $(cat /usr/share/themes/Yaru-blue-dark/gnome-shell/gnome-shell.css | grep "THEME OVERRIDE") ]]; then
        sudo tee --append /usr/share/themes/Yaru-blue-dark/gnome-shell/gnome-shell.css >$OUTPUT_EMPTY 2>&1 <<EOT

/* THEME OVERRIDE */
#panel,
#panel:overview { background-color: rgb(34,34,34); }
EOT
    fi

    sudo wget \
        --output-document="/usr/bin/stylepak" \
        --quiet \
        "https://raw.githubusercontent.com/refi64/stylepak/master/stylepak"

    sudo chmod +x /usr/bin/stylepak

    flatpak remove --assumeyes --user org.gtk.Gtk3theme.Yaru-blue-dark >$OUTPUT_EMPTY 2>&1 || true
    stylepak install-user >$OUTPUT_EMPTY 2>&1
}

# ################################################################
# Main
# ################################################################

trap 'handle_errors $LINENO "$BASH_COMMAND"' ERR
sudo echo -e "[ Fedora Workstation Update Script ]\n"

parse_commandline "$@"

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

log_success
