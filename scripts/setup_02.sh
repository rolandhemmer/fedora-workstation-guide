#!/bin/bash

source __common__.sh

# --------------------------------
# Functions
# --------------------------------

00_configure_desktop() {
    __log_title__ "\n==> Configuring desktop"

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
    # Configuring desktop theme
    # ################################################################

    __log_progress__ "Configuring desktop theme"

    gsettings set org.gnome.desktop.interface document-font-name "Roboto 11"
    gsettings set org.gnome.desktop.interface font-name "Roboto 11"
    gsettings set org.gnome.desktop.interface monospace-font-name "Roboto Mono 11"
    gsettings set org.gnome.desktop.wm.preferences titlebar-font "Roboto 11"

    sudo fc-cache --really-force

    gsettings set org.gnome.desktop.interface gtk-theme "Colloid-Dark"
    gsettings set org.gnome.desktop.interface icon-theme "Colloid-dark"
    gsettings set org.gnome.desktop.interface cursor-theme "Colloid-cursors"
    gsettings set org.gnome.shell.extensions.user-theme name "Colloid-Dark"

    stylepak install-user >$NO_OUTPUT 2>&1

    __log_success__ "Configuring desktop theme"
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


# --------------------------------
# Main
# --------------------------------

set -e
sudo echo ""

cat <<"EOT"
    ________________  ____  ____  ___       _____ ______________  ______
   / ____/ ____/ __ \/ __ \/ __ \/   |     / ___// ____/_  __/ / / / __ \
  / /_  / __/ / / / / / / / /_/ / /| |     \__ \/ __/   / / / / / / /_/ /
 / __/ / /___/ /_/ / /_/ / _, _/ ___ |    ___/ / /___  / / / /_/ / ____/
/_/   /_____/_____/\____/_/ |_/_/  |_|   /____/_____/ /_/  \____/_/

EOT

00_configure_desktop
01_configure_desktop_extensions

echo -e "\n[ ${ECHO_BOLD}OK${ECHO_RESET} ]"
