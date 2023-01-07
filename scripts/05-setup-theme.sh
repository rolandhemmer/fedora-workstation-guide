#!/bin/bash

# ################################################################
# FUNCTIONS
# ################################################################

export ECHO_BOLD="\033[1m"
export ECHO_GREEN="\033[1;32m"
export ECHO_GREY="\033[0;37m"
export ECHO_RED="\033[1;31m"
export ECHO_RESET="\033[0m"
export ECHO_REPLACE="\033[1A\033[K"

export NO_OUTPUT="/dev/null"

ask_reboot() {
    while true; do
        echo -e "\nA reboot is required to continue. Do you wish to reboot now?"
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

flatpak_install() {
    flatpak install --assumeyes --user flathub $@ >$NO_OUTPUT 2>&1
}

dnf_group_install() {
    sudo dnf group install --allowerasing --assumeyes --best --quiet $@ >$NO_OUTPUT 2>&1
}

dnf_group_update() {
    sudo dnf group update allowerasing --assumeyes --best --quiet --with-optional $@ >$NO_OUTPUT 2>&1
}

dnf_package_install() {
    sudo dnf install --allowerasing --assumeyes --best --quiet $@ >$NO_OUTPUT 2>&1
}

dnf_package_remove() {
    sudo dnf remove --assumeyes --quiet $@ >$NO_OUTPUT 2>&1
}

log_progress() {
    echo -e "[ .. ]\t$1"
}

log_success() {
    echo -e "${ECHO_REPLACE}[ ${ECHO_GREEN}OK${ECHO_RESET} ]\t$1"
}

log_success_alt() {
    echo -e "[ ${ECHO_GREEN}OK${ECHO_RESET} ]\t$1"
}

log_title() {
    echo -e "${ECHO_BOLD}$1${ECHO_RESET}"
}

# ################################################################
# SETUP
# ################################################################

set -e
sudo echo ""

cat <<"EOT"
    ________________  ____  ____  ___       _____ ______________  ______
   / ____/ ____/ __ \/ __ \/ __ \/   |     / ___// ____/_  __/ / / / __ \
  / /_  / __/ / / / / / / / /_/ / /| |     \__ \/ __/   / / / / / / /_/ /
 / __/ / /___/ /_/ / /_/ / _, _/ ___ |    ___/ / /___  / / / /_/ / ____/
/_/   /_____/_____/\____/_/ |_/_/  |_|   /____/_____/ /_/  \____/_/

EOT

log_title "\n==> Installing desktop theme"

# ----------------------------------------------------------------
# Installing terminal theme
# ----------------------------------------------------------------

log_progress "Installing terminal theme"

dnf_package_install \
    powerline \
    powerline-fonts \
    vim-powerline

tee --append ~/.bashrc >$NO_OUTPUT 2>&1 <<EOT
if [ -f $(which powerline-daemon) ]; then
    powerline-daemon --quiet
    POWERLINE_BASH_CONTINUATION=1
    POWERLINE_BASH_SELECT=1
    . /usr/share/powerline/bash/powerline.sh
fi
EOT

tee --append ~/.vimrc >$NO_OUTPUT 2>&1 <<EOT
if [ -f $(which powerline-daemon) ]; then
    powerline-daemon --quiet
    POWERLINE_BASH_CONTINUATION=1
    POWERLINE_BASH_SELECT=1
    . /usr/share/powerline/bash/powerline.sh
fi
EOT

sudo cp ~/.bashrc /root/.bashrc >$NO_OUTPUT 2>&1
sudo cp ~/.vimrc /root/.vimrc >$NO_OUTPUT 2>&1

log_success "Installing terminal theme"

# ----------------------------------------------------------------
# Installing desktop fonts
# ----------------------------------------------------------------

log_progress "Installing desktop fonts"

dnf_package_install \
    google-roboto-fonts \
    google-roboto-mono-fonts

log_success "Installing desktop fonts"

# ----------------------------------------------------------------
# Installing shell theme
# ----------------------------------------------------------------

log_progress "Installing shell theme"

mkdir --parents ~/.setup/shell || true

dnf_package_install \
    gtk-murrine-engine \
    gnome-themes-extra \
    gnome-themes-standard \
    libappindicator-gtk3 \
    sassc

cd ~/.setup/shell
git clone --quiet "https://github.com/vinceliuice/Colloid-gtk-theme.git" Colloid >$NO_OUTPUT 2>&1 || true
cd Colloid

sudo ./install.sh \
    --color dark \
    --libadwaita \
    --theme default \
    --tweaks rimless >$NO_OUTPUT 2>&1

log_success "Installing shell theme"

# ----------------------------------------------------------------
# Installing icon theme
# ----------------------------------------------------------------

log_progress "Installing icon theme"

mkdir --parents ~/.setup/icons || true

cd ~/.setup/icons
git clone --quiet "https://github.com/vinceliuice/Colloid-icon-theme.git" Colloid >$NO_OUTPUT 2>&1 || true
cd Colloid

sudo ./install.sh \
    --scheme default \
    --theme default >$NO_OUTPUT 2>&1

log_success "Installing icon theme"

# ----------------------------------------------------------------
# Installing cursor theme
# ----------------------------------------------------------------

log_progress "Installing cursor theme"

mkdir --parents ~/.setup/cursors || true

cd ~/.setup/cursors
git clone --quiet "https://github.com/vinceliuice/Colloid-icon-theme.git" Colloid >$NO_OUTPUT 2>&1 || true
cd Colloid/cursors

sudo ./install.sh >$NO_OUTPUT 2>&1

log_success "Installing cursor theme"

# ----------------------------------------------------------------
# Configuring desktop settings
# ----------------------------------------------------------------

log_progress "Configuring desktop settings"

dnf_package_install gnome-tweaks

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
# Configuring desktop theme
# ----------------------------------------------------------------

log_progress "Configuring desktop theme"

gsettings set org.gnome.desktop.interface document-font-name "Roboto 11"
gsettings set org.gnome.desktop.interface font-name "Roboto 11"
gsettings set org.gnome.desktop.interface monospace-font-name "Roboto Mono 11"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "Roboto 11"

sudo fc-cache --really-force

gsettings set org.gnome.desktop.interface gtk-theme "Colloid-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Colloid-dark"
gsettings set org.gnome.desktop.interface cursor-theme "Colloid-cursors"
gsettings set org.gnome.shell.extensions.user-theme name "Colloid-Dark"

log_success "Configuring desktop theme"

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

# ################################################################
# DONE
# ################################################################

echo -e "\n[ ${ECHO_BOLD}OK${ECHO_RESET} ]"
