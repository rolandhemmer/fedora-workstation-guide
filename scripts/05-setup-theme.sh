#!/bin/bash

source common.sh

# ################################################################
# Main
# ################################################################

trap 'handle_errors $LINENO "$BASH_COMMAND"' ERR
sudo echo -e "[ Fedora Workstation Installation Script ]\n"

# ----------------------------------------------------------------

# Installing terminal theme
log_step "Installing terminal theme"

dnf_package_install \
    powerline \
    powerline-fonts \
    vim-powerline

tee --append $HOME/.bashrc >$OUTPUT_EMPTY 2>&1 <<EOT
if [ -f $(which powerline-daemon) ]; then
    powerline-daemon --quiet
    POWERLINE_BASH_CONTINUATION=1
    POWERLINE_BASH_SELECT=1
    . /usr/share/powerline/bash/powerline.sh
fi
EOT

tee $HOME/.vimrc >$OUTPUT_EMPTY 2>&1 <<EOT
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
set laststatus=2 " Always display the statusline in all windows
set showtabline=2 " Always display the tabline, even if there is only one tab
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
set t_Co=256
EOT

sudo cp $HOME/.bashrc /root/.bashrc >$OUTPUT_EMPTY 2>&1
sudo cp $HOME/.vimrc /root/.vimrc >$OUTPUT_EMPTY 2>&1

tee $HOME/.config/gtk-3.0/gtk.css >$OUTPUT_EMPTY 2>&1 <<EOT
VteTerminal,
TerminalScreen,
vte-terminal {
    padding: 10px 10px 10px 10px;
    -VteTerminal-inner-border: 10px 10px 10px 10px;
}
EOT

# ----------------------------------------------------------------

# Installing GNOME theme
log_step "Installing GNOME theme"

dnf_package_install \
    google-roboto-fonts \
    google-roboto-mono-fonts \
    yaru-theme

gsettings set org.gnome.desktop.interface cursor-theme "Yaru"
gsettings set org.gnome.desktop.interface gtk-theme "Yaru-blue-dark"
gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue-dark"
gsettings set org.gnome.desktop.sound theme-name "Yaru"

sudo tee --append /usr/share/themes/Yaru-blue-dark/gnome-shell/gnome-shell.css >$OUTPUT_EMPTY 2>&1 <<EOT

/* THEME OVERRIDE */
#panel,
#panel:overview { background-color: rgb(34,34,34); }
EOT

gsettings set org.gnome.desktop.interface document-font-name "Roboto 11"
gsettings set org.gnome.desktop.interface font-name "Roboto 11"
gsettings set org.gnome.desktop.interface monospace-font-name "Roboto Mono 11"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "Roboto 11"

sudo fc-cache --really-force

# ----------------------------------------------------------------

# Configuring GNOME theme for sandboxed applications
log_step "Configuring GNOME theme for sandboxed applications"

dnf_package_install \
    libappstream-glib \
    ostree

sudo wget \
    --output-document="/usr/bin/stylepak" \
    --quiet \
    "https://raw.githubusercontent.com/refi64/stylepak/master/stylepak"

sudo chmod +x /usr/bin/stylepak

stylepak install-user >$OUTPUT_EMPTY 2>&1

# ----------------------------------------------------------------

# Configuring GNOME update settings
log_step "Configuring GNOME update settings"

## Disable the gnome-software shell search provider
sudo tee --append /usr/share/gnome-shell/search-providers/org.gnome.Software-search-provider.ini >$OUTPUT_EMPTY 2>&1 <<EOT
DefaultDisabled=true
EOT

## Disable gnome-software automatically downloading updates
sudo tee --append /usr/share/glib-2.0/schemas/org.gnome.software.gschema.override >$OUTPUT_EMPTY 2>&1 <<EOT
[org.gnome.software]
download-updates=false
EOT

## Do not start gnome-software session service at boot
sudo rm --force /etc/xdg/autostart/gnome-software-service.desktop

# ----------------------------------------------------------------

# Configuring GNOME desktop settings
log_step "Configuring GNOME desktop settings"

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

# ################################################################
# End
# ################################################################

log_success
