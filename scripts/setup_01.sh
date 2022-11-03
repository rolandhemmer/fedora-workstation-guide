#!/bin/bash

source __common__.sh

# --------------------------------
# Functions
# --------------------------------

00_install_desktop_prerequisites() {
    __log_title__ "\n==> Installing desktop prerequisites"

    # ################################################################
    # Installing desktop fonts
    # ################################################################

    __log_progress__ "Installing desktop fonts"

    __install_dnf__ \
        google-roboto-fonts \
        google-roboto-mono-fonts >$NO_OUTPUT 2>&1

    __log_success__ "Installing desktop fonts"

    # ################################################################
    # Installing shell theme
    # ################################################################

    __log_progress__ "Installing shell theme"

    mkdir --parents ~/.setup/shell || true

    __install_dnf__ \
        gtk-murrine-engine \
        gnome-themes-extra \
        gnome-themes-standard \
        sassc

    cd ~/.setup/shell
    git clone --quiet "https://github.com/vinceliuice/Colloid-gtk-theme.git" Colloid >$NO_OUTPUT 2>&1
    cd Colloid

    sudo ./install.sh \
        --color dark \
        --libadwaita \
        --theme default \
        --tweaks rimless >$NO_OUTPUT 2>&1

    mkdir --parents ~/.setup/tools || true

    __install_dnf__ \
        libappstream-glib \
        ostree

    cd ~/.setup/tools
    git clone --quiet "https://github.com/refi64/stylepak.git" stylepak >$NO_OUTPUT 2>&1
    cd stylepak

    chmod +x stylepak
    sudo cp stylepak /usr/bin/

    __log_success__ "Installing shell theme"

    # ################################################################
    # Installing icon theme
    # ################################################################

    __log_progress__ "Installing icon theme"

    mkdir --parents ~/.setup/icons || true

    cd ~/.setup/icons
    git clone --quiet "https://github.com/vinceliuice/Colloid-icon-theme.git" Colloid >$NO_OUTPUT 2>&1
    cd Colloid

    sudo ./install.sh \
        --scheme default \
        --theme default >$NO_OUTPUT 2>&1

    __log_success__ "Installing icon theme"

    # ################################################################
    # Installing cursor theme
    # ################################################################

    __log_progress__ "Installing cursor theme"

    mkdir --parents ~/.setup/cursors || true

    cd ~/.setup/cursors
    git clone --quiet "https://github.com/vinceliuice/Colloid-icon-theme.git" Colloid >$NO_OUTPUT 2>&1
    cd Colloid/cursors

    sudo ./install.sh >$NO_OUTPUT 2>&1

    __log_success__ "Installing cursor theme"
}

01_install_desktop_extensions() {
    __log_title__ "\n==> Installing desktop extensions"

    # ################################################################
    # Enabling desktop extensions support
    # ################################################################

    __log_progress__ "Enabling desktop extensions support"

    __install_dnf__ gnome-tweaks
    __install_flatpak__ "org.gnome.Extensions"

    __install_dnf__ \
        bash \
        curl \
        dbus \
        git \
        less \
        perl

    cd ~/.setup/tools
    git clone --quiet "https://github.com/brunelli/gnome-shell-extension-installer.git" gnome-shell-extension-installer >$NO_OUTPUT 2>&1
    cd gnome-shell-extension-installer

    chmod +x gnome-shell-extension-installer
    sudo cp gnome-shell-extension-installer /usr/bin/

    __log_success__ "Enabling desktop extensions support"

    # ################################################################
    # Installing desktop extensions
    # ################################################################

    __log_progress__ "Installing desktop extensions"

    cd /usr/share/glib-2.0/schemas
    sudo wget --quiet "https://raw.githubusercontent.com/stuarthayhurst/alphabetical-grid-extension/master/extension/schemas/org.gnome.shell.extensions.AlphabeticalAppGrid.gschema.xml"
    sudo wget --quiet "https://raw.githubusercontent.com/aunetx/blur-my-shell/master/schemas/org.gnome.shell.extensions.blur-my-shell.gschema.xml"
    sudo wget --quiet "https://raw.githubusercontent.com/micheleg/dash-to-dock/master/schemas/org.gnome.shell.extensions.dash-to-dock.gschema.xml"
    sudo wget --quiet "https://gitlab.gnome.org/GNOME/gnome-shell-extensions/-/raw/main/extensions/user-theme/org.gnome.shell.extensions.user-theme.gschema.xml"
    sudo wget --quiet "https://raw.githubusercontent.com/tuxor1337/hidetopbar/master/schemas/org.gnome.shell.extensions.hidetopbar.gschema.xml"
    sudo wget --quiet "https://raw.githubusercontent.com/MartinPL/Tray-Icons-Reloaded/master/schemas/org.gnome.shell.extensions.trayIconsReloaded.gschema.xml"
    sudo glib-compile-schemas . >$NO_OUTPUT 2>&1

    gnome-shell-extension-installer --yes 4269 3193 307 19 545 2890 >$NO_OUTPUT 2>&1

    __log_success__ "Installing desktop extensions"
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

00_install_desktop_prerequisites
01_install_desktop_extensions

echo -e "\n[ ${ECHO_BOLD}OK${ECHO_RESET} ]"
