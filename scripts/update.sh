#!/bin/bash
#
# Generated using Argbash v2.9.0
# See https://argbash.io for more
#

# --------------------------------
# Arguments Parsing and Management
# --------------------------------

_arg_all="off"
_arg_system="off"
_arg_extensions="off"
_arg_theme="off"
_arg_luks_partition=

die() {
    local _ret="${2:-1}"
    test "${_PRINT_HELP:-no}" = yes && print_help >&2
    echo -e "[ ${ECHO_RED}KO${ECHO_RESET} ]\t$1" >&2
    exit "${_ret}"
}

begins_with_short_option() {
    local first_option all_short_options='asetlh'
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
        -e | --no-extensions | --extensions)
            _arg_extensions="on"
            test "${1:0:5}" = "--no-" && _arg_extensions="off"
            ;;
        -e*)
            _arg_extensions="on"
            _next="${_key##-e}"
            if test -n "$_next" -a "$_next" != "$_key"; then
                { begins_with_short_option "$_next" && shift && set -- "-e" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
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
        -l | --luks-partition)
            test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
            _arg_luks_partition="$2"
            shift
            ;;
        --luks-partition=*)
            _arg_luks_partition="${_key##--luks-partition=}"
            ;;
        -l*)
            _arg_luks_partition="${_key##-l}"
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
    printf 'Usage: %s [-a|--all] [-s|--system] [-e|--extensions] [-t|--theme] [-l|--luks-partition <arg>] [-h|--help]\n' "$0"
    printf '\t%s\t\t%s\n' "-a, --all" "Updates everything (system, extensions, and theme)"
    printf '\t%s\t\t%s\n' "-s, --system" "Updates only system packages and applications"
    printf '\t%s\t%s\n' "-e, --extensions" "Updates only GNOME extensions"
    printf '\t%s\t\t%s\n' "-t, --theme" "Updates only GNOME theme (shell, cursors, and icons)"
    printf '\t%s\t%s\t%s\n' "-l, --luks-partition" "Partition name of the LUKS container to be automatically decrypted using the TPM chip" "(e.g: /dev/sda1)"
    printf '\t%s\t\t%s\n' "-h, --help" "Prints help"
}

# --------------------------------
# Functions
# --------------------------------

__git_reset__() {
    git clean -dx --force >$NO_OUTPUT 2>&1 || true
    git checkout . >$NO_OUTPUT 2>&1
    git fetch --all --prune --prune-tags --tags >$NO_OUTPUT 2>&1
    git remote prune origin >$NO_OUTPUT 2>&1
    git pull --rebase >$NO_OUTPUT 2>&1
    git gc --aggressive --prune=now >$NO_OUTPUT 2>&1
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

00_update_system() {
    # ################################################################
    # Updating and cleaning system applications
    # ################################################################

    __log_progress__ "Updating and cleaning system applications"

    sudo flatpak update --system --assumeyes >$NO_OUTPUT
    sudo flatpak uninstall --system --assumeyes --unused >$NO_OUTPUT

    __log_success__ "Updating and cleaning system applications"

    # ################################################################
    # Updating and cleaning user applications
    # ################################################################

    __log_progress__ "Updating and cleaning user applications"

    flatpak update --user --assumeyes >$NO_OUTPUT
    flatpak uninstall --user --assumeyes --unused >$NO_OUTPUT

    flatpak override --user --reset
    flatpak override --user --device=dri

    __log_success__ "Updating and cleaning user applications"

    # ################################################################
    # Performing a full system upgrade
    # ################################################################

    __log_progress__ "Performing a full system upgrade"

    sudo dnf upgrade --assumeyes --quiet --refresh >$NO_OUTPUT

    __log_success__ "Performing a full system upgrade"

    # ################################################################
    # Updating system drivers
    # ################################################################

    __log_progress__ "Updating system drivers"

    # The 'fwupdmgr' command exits with '1' (as failure) when no update is needed
    sudo fwupdmgr --assume-yes --force refresh >$NO_OUTPUT 2>&1 || true
    sudo fwupdmgr --assume-yes --force get-updates >$NO_OUTPUT 2>&1 || true

    __log_success__ "Updating system drivers"
}

01_update_extensions() {
    # ################################################################
    # Updating desktop extensions
    # ################################################################

    __log_progress__ "Updating desktop extensions"

    cd /usr/share/glib-2.0/schemas
    sudo wget --quiet "https://raw.githubusercontent.com/stuarthayhurst/alphabetical-grid-extension/master/extension/schemas/org.gnome.shell.extensions.AlphabeticalAppGrid.gschema.xml"
    sudo wget --quiet "https://raw.githubusercontent.com/aunetx/blur-my-shell/master/schemas/org.gnome.shell.extensions.blur-my-shell.gschema.xml"
    sudo wget --quiet "https://raw.githubusercontent.com/micheleg/dash-to-dock/master/schemas/org.gnome.shell.extensions.dash-to-dock.gschema.xml"
    sudo wget --quiet "https://gitlab.gnome.org/GNOME/gnome-shell-extensions/-/raw/main/extensions/user-theme/org.gnome.shell.extensions.user-theme.gschema.xml"
    sudo wget --quiet "https://raw.githubusercontent.com/tuxor1337/hidetopbar/master/schemas/org.gnome.shell.extensions.hidetopbar.gschema.xml"
    sudo wget --quiet "https://raw.githubusercontent.com/MartinPL/Tray-Icons-Reloaded/master/schemas/org.gnome.shell.extensions.trayIconsReloaded.gschema.xml"
    sudo glib-compile-schemas . >$NO_OUTPUT 2>&1

    cd ~/.setup/tools/gnome-shell-extension-installer
    __git_reset__
    sudo cp gnome-shell-extension-installer /usr/bin/

    gnome-shell-extension-installer --update --yes >$NO_OUTPUT 2>&1

    gnome-extensions disable AlphabeticalAppGrid@stuarthayhurst
    gnome-extensions disable blur-my-shell@aunetx
    gnome-extensions disable dash-to-dock@micxgx.gmail.com
    gnome-extensions disable hidetopbar@mathieu.bidon.ca
    gnome-extensions disable trayIconsReloaded@selfmade.pl
    gnome-extensions disable user-theme@gnome-shell-extensions.gcampax.github.com

    gnome-extensions enable AlphabeticalAppGrid@stuarthayhurst
    gnome-extensions enable blur-my-shell@aunetx
    gnome-extensions enable dash-to-dock@micxgx.gmail.com
    gnome-extensions enable hidetopbar@mathieu.bidon.ca
    gnome-extensions enable trayIconsReloaded@selfmade.pl
    gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com

    __log_success__ "Updating desktop extensions"

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

02_update_theme() {
    # ################################################################
    # Configuring desktop settings
    # ################################################################

    __log_progress__ "Configuring desktop settings"

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

    __log_success__ "Configuring desktop settings"

    # ################################################################
    # Configuring desktop fonts
    # ################################################################

    __log_progress__ "Configuring desktop fonts"

    gsettings set org.gnome.desktop.interface document-font-name "Roboto 11"
    gsettings set org.gnome.desktop.interface font-name "Roboto 11"
    gsettings set org.gnome.desktop.interface monospace-font-name "Roboto Mono 11"
    gsettings set org.gnome.desktop.wm.preferences titlebar-font "Roboto 11"

    sudo fc-cache --really-force

    __log_success__ "Configuring desktop fonts"

    # ################################################################
    # Updating shell theme
    # ################################################################

    __log_progress__ "Updating shell theme"

    cd ~/.setup/shell/Colloid
    __git_reset__

    sudo ./install.sh \
        --color dark \
        --libadwaita \
        --theme default \
        --tweaks rimless >$NO_OUTPUT 2>&1

    gsettings set org.gnome.desktop.interface gtk-theme "Colloid-Dark"
    gsettings set org.gnome.shell.extensions.user-theme name "Colloid-Dark"

    cd ~/.setup/tools/stylepak
    __git_reset__

    stylepak install-user >$NO_OUTPUT

    __log_success__ "Updating shell theme"

    # ################################################################
    # Updating icon theme
    # ################################################################

    __log_progress__ "Updating icon theme"

    cd ~/.setup/icons/Colloid
    __git_reset__

    sudo ./install.sh \
        --scheme default \
        --theme default >$NO_OUTPUT 2>&1

    gsettings set org.gnome.desktop.interface icon-theme "Colloid-dark"

    __log_success__ "Updating icon theme"

    # ################################################################
    # Updating cursor theme
    # ################################################################

    __log_progress__ "Updating cursor theme"

    cd ~/.setup/cursors/Colloid/cursors
    __git_reset__

    sudo ./install.sh >$NO_OUTPUT 2>&1

    gsettings set org.gnome.desktop.interface cursor-theme "Colloid-cursors"

    __log_success__ "Updating cursor theme"
}

03_update_tpm() {
    # ################################################################
    # Updating TPM for '${_arg_luks_partition}' auto-decryption
    # ################################################################

    __log_progress__ "Updating TPM for '${_arg_luks_partition}' auto-decryption"

    sudo systemd-cryptenroll \
        --tpm2-device=auto \
        --tpm2-pcrs=7+8 \
        ${_arg_luks_partition}

    sudo sed --in-place --expression \
        "/^luks-/s/$/,tpm2-device=auto/" \
        /etc/crypttab

    echo 'install_optional_items+=" /usr/lib64/libtss2* /usr/lib64/libfido2.so.* /usr/lib64/cryptsetup/libcryptsetup-token-systemd-tpm2.so "' | sudo tee /etc/dracut.conf.d/tss2.conf >$NO_OUTPUT

    sudo dracut --force

    __log_success_alt__ "Updating TPM for '${_arg_luks_partition}' auto-decryption"
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

neofetch

if [ ${_arg_all} = "on" ]; then
    _arg_system="on"
    _arg_extensions="on"
    _arg_theme="on"
fi

if [ ${_arg_system} = "on" ]; then
    00_update_system
fi

if [ ${_arg_extensions} = "on" ]; then
    01_update_extensions
fi

if [ ${_arg_theme} = "on" ]; then
    02_update_theme
fi

if [ ${_arg_luks_partition} ]; then
    echo ""
    03_update_tpm
fi

if [ ${_arg_system} = "off" ] && [ ${_arg_extensions} = "off" ] && [ ${_arg_theme} = "off" ] && [ -z ${_arg_luks_partition} ]; then
    print_help
fi

echo -e "\n[ ${ECHO_BOLD}OK${ECHO_RESET} ]"
