#!/bin/bash
#
# Generated using Argbash v2.9.0
# See https://argbash.io for more
#

# --------------------------------
# Arguments Parsing and Management
# --------------------------------

_arg_nvidia_drivers="off"
_arg_luks_partition=

begins_with_short_option() {
    local first_option all_short_options='nlh'
    first_option="${1:0:1}"
    test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

die() {
    local _ret="${2:-1}"
    test "${_PRINT_HELP:-no}" = yes && print_help >&2
    echo "$1" >&2
    exit "${_ret}"
}

parse_commandline() {
    while test $# -gt 0; do
        _key="$1"
        case "$_key" in
        -n | --no-nvidia-drivers | --nvidia-drivers)
            _arg_nvidia_drivers="on"
            test "${1:0:5}" = "--no-" && _arg_nvidia_drivers="off"
            ;;
        -n*)
            _arg_nvidia_drivers="on"
            _next="${_key##-n}"
            if test -n "$_next" -a "$_next" != "$_key"; then
                { begins_with_short_option "$_next" && shift && set -- "-n" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
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
            _PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
            ;;
        esac
        shift
    done
}

print_help() {
    printf '%s\n' "Fedora Workstation Personal Installation Script"
    printf 'Usage: %s [-n|--(no-)nvidia-drivers] [-l|--luks-partition <arg>] [-h|--help]\n' "$0"
    printf '\t%s\n' "-n, --nvidia-drivers, --no-nvidia-drivers: include latest Nvidia drivers with installation (off by default)"
    printf '\t%s\n' "-l, --luks-partition: Partition name of the LUKS container to be automatically decrypted using the TPM chip (e.g: /dev/sda1) (no default)"
    printf '\t%s\n' "-h, --help: Prints help"
}

# --------------------------------
# Functions
# --------------------------------

_install_flatpak() {
    flatpak install --assumeyes --user flathub $1 >$NO_OUTPUT 2>&1
}

_log_progress() {
    echo -e "[ .. ]\t${ECHO_GREY}$1${ECHO_RESET}"
}

_log_success() {
    echo -e "[ ${ECHO_GREEN}OK${ECHO_RESET} ]\t${ECHO_GREY}$1${ECHO_RESET}"
}

_log_success_and_replace() {
    echo -e "${ECHO_REPLACE}[ ${ECHO_GREEN}OK${ECHO_RESET} ]\t${ECHO_GREY}$1${ECHO_RESET}"
}

_log_title() {
    echo -e "${ECHO_BOLD}$1${ECHO_RESET}"
}

00_update_system() {
    _log_title "==> Updating system"

    # ################################################################
    # Updating DNF settings
    # ################################################################

    _log_progress "Updating DNF settings"
    sudo tee --append /etc/dnf/dnf.conf >$NO_OUTPUT <<EOT
deltarpm=true
fastestmirror=1
max_parallel_downloads=20
EOT
    _log_success_and_replace "Updating DNF settings"

    # ################################################################
    # Enabling the Flathub repository
    # ################################################################

    _log_progress "Enabling the Flathub repository"

    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >$NO_OUTPUT

    _log_success_and_replace "Enabling the Flathub repository"

    # ################################################################
    # Updating and cleaning system applications
    # ################################################################

    _log_progress "Updating and cleaning system applications"

    sudo flatpak repair --system >$NO_OUTPUT
    sudo flatpak update --system --assumeyes >$NO_OUTPUT
    sudo flatpak uninstall --system --assumeyes --unused >$NO_OUTPUT

    _log_success_and_replace "Updating and cleaning system applications"

    # ################################################################
    # Updating and cleaning user applications
    # ################################################################

    _log_progress "Updating and cleaning user applications"

    flatpak repair --user >$NO_OUTPUT
    flatpak update --user --assumeyes >$NO_OUTPUT
    flatpak uninstall --user --assumeyes --unused >$NO_OUTPUT

    flatpak override --user --reset

    flatpak override --user --device=dri
    flatpak override --user --filesystem=~/.local/share/themes
    flatpak override --user --filesystem=~/.local/share/icons

    _log_success_and_replace "Updating and cleaning user applications"

    # ################################################################
    # Enabling the Fedora RPM Fusion repositories
    # ################################################################

    _log_progress "Enabling the Fedora RPM Fusion repositories"

    sudo dnf install --assumeyes --quiet https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm >$NO_OUTPUT
    sudo dnf install --assumeyes --quiet https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm >$NO_OUTPUT

    sudo dnf install --assumeyes --quiet \
        fedora-workstation-repositories \
        rpmfusion-free-appstream-data \
        rpmfusion-nonfree-appstream-data >$NO_OUTPUT

    sudo dnf group update core --assumeyes --quiet >$NO_OUTPUT

    _log_success_and_replace "Enabling the Fedora RPM Fusion repositories"

    # ################################################################
    # Performing a full system upgrade
    # ################################################################

    _log_progress "Performing a full system upgrade"

    sudo dnf upgrade --assumeyes --quiet --refresh >$NO_OUTPUT

    _log_success_and_replace "Performing a full system upgrade"

    # ################################################################
    # Updating system drivers
    # ################################################################

    _log_progress "Updating system drivers"

    sudo dnf install --assumeyes --quiet fwupd

    # The 'fwupdmgr' command exits with '1' (as failure) when no update is needed
    sudo fwupdmgr --assume-yes --force refresh >$NO_OUTPUT 2>&1 || true
    sudo fwupdmgr --assume-yes --force get-updates >$NO_OUTPUT 2>&1 || true

    _log_success_and_replace "Updating system drivers"

    # ################################################################
    # Installing Preload
    # ################################################################

    _log_progress "Installing Preload"

    sudo dnf copr enable --assumeyes elxreno/preload >$NO_OUTPUT 2>&1
    sudo dnf install --assumeyes --quiet preload >$NO_OUTPUT
    sudo systemctl start preload >$NO_OUTPUT
    sudo systemctl enable preload >$NO_OUTPUT

    _log_success_and_replace "Installing Preload"
}

01_install_nvidia_drivers() {
    _log_title "\n==> Installing latest Nvidia drivers"

    # ################################################################
    # Installing prerequisites
    # ################################################################

    _log_progress "Installing prerequisites"

    sudo dnf install --assumeyes --quiet \
        akmods \
        acpid \
        curl \
        dkms \
        gcc \
        git \
        kernel-devel \
        kernel-headers \
        libglvnd-glx \
        libglvnd-opengl \
        libglvnd-devel \
        make \
        mokutil \
        openssl \
        pkgconfig \
        vim \
        wget >$NO_OUTPUT

    _log_success_and_replace "Installing prerequisites"

    # ################################################################
    # Enabling Nvidia kernel module auto-signing
    # ################################################################

    _log_progress "Enabling Nvidia kernel module auto-signing"

    sudo kmodgenca --auto >$NO_OUTPUT
    sudo mokutil --import /etc/pki/akmods/certs/public_key.der >$NO_OUTPUT

    _log_success "Enabling Nvidia kernel module auto-signing"

    # ################################################################
    # Installing latest Nvidia drivers
    # ################################################################

    _log_progress "Installing latest Nvidia drivers"

    sudo dnf config-manager --set-enable rpmfusion-nonfree-nvidia-driver >$NO_OUTPUT

    sudo dnf install --assumeyes --quiet \
        akmod-nvidia \
        libva-utils \
        libva-vdpau-driver \
        vdpauinfo \
        xorg-x11-drv-nvidia \
        xorg-x11-drv-nvidia-cuda \
        xorg-x11-drv-nvidia-cuda-libs \
        xorg-x11-drv-nvidia-libs \
        xorg-x11-drv-nvidia-libs.i686 \
        vulkan-loader \
        vulkan-loader.i686 >$NO_OUTPUT

    echo "%global _with_kmod_nvidia_open 1" | sudo tee /etc/rpm/macros-nvidia-kmod >$NO_OUTPUT
    sudo akmods --force >$NO_OUTPUT
    sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1' >$NO_OUTPUT

    echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >$NO_OUTPUT
    sudo tee /etc/dracut.conf.d/nvidia.conf >$NO_OUTPUT <<EOT
add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "
install_items+=" /etc/modprobe.d/nvidia.conf "
EOT
    sudo dracut --force

    _log_success_and_replace "Installing latest Nvidia drivers"
}

02_harden_system() {
    _log_title "\n==> Hardening system"

    # ################################################################
    # Enabling kernel self-protection parameters
    # ################################################################

    _log_progress "Enabling kernel self-protection parameters"

    sudo tee /etc/sysctl.conf >$NO_OUTPUT <<EOT
## Kernel Self-Protection

# Reduces buffer overflows attacks
kernel.randomize_va_space=2

# Mitigates kernel pointer leaks
kernel.kptr_restrict=2

# Restricts the kernel log to the CAP_SYSLOG capability
kernel.dmesg_restrict=1
kernel.printk=3 3 3 3

# Restricts eBPF and reduce its attack surface
kernel.unprivileged_bpf_disabled=1

# Enables JIT hardening techniques
net.core.bpf_jit_harden=2

# Restricts loading TTY line disciplines to the CAP_SYS_MODULE capability
dev.tty.ldisc_autoload=0

# Restricts the userfaultfd() syscall to the CAP_SYS_PTRACE capability
vm.unprivileged_userfaultfd=0

# Disables the kexec system call to avoid abuses
kernel.kexec_load_disabled=1

# Disables the SysRq key completely
kernel.sysrq=0

# Restricts most of the performance events to the CAP_PERFMON capability
kernel.perf_event_paranoid=2

## Network Protection

# Protects against SYN flood attacks
net.ipv4.tcp_syncookies=1

# Protects against time-wait assassination
net.ipv4.tcp_rfc1337=1

# Protects against IP spoofing
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1

# Prevent man-in-the-middle attacks and minimize information disclosure
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.all.log_martians=1
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.default.log_martians=1
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.default.accept_redirects=0

# Avoids Smurf attacks and prevent clock fingerprinting through ICMP timestamps
net.ipv4.icmp_echo_ignore_all=1

## User Space Protection

# Prevents hard links from being created by users that do not have read/write access to the source file, and prevent common TOCTOU races
fs.protected_symlinks=1
fs.protected_hardlinks=1

# Prevents creating files in potentially attacker-controlled environments
fs.protected_fifos=2
fs.protected_regular=2

# Prevents processes with elevated privileges to dump their memory
fs.suid_dumpable=0

EOT

    sudo sysctl -p >$NO_OUTPUT
    _log_success_and_replace "Enabling kernel self-protection parameters"

    # ################################################################
    # Enabling recommended boot parameters
    # ################################################################

    _log_progress "Enabling recommended boot parameters"

    sudo grubby --update-kernel=ALL --args="debugfs=off init_on_alloc=1 init_on_free=1 lockdown=confidentiality loglevel=0 module.sig_enforce=1 page_alloc.shuffle=1 pti=on randomize_kstack_offset=on slab_nomerge spectre_v2=on spec_store_bypass_disable=on tsx=off tsx_async_abort=full,nosmt mds=full,nosmt l1tf=full,force nosmt=force kvm.nx_huge_pages=force vsyscall=none"

    _log_success_and_replace "Enabling recommended boot parameters"

    # ################################################################
    # Enabling the Random Number Generator service
    # ################################################################

    _log_progress "Enabling the Random Number Generator service"

    sudo dnf install --assumeyes --quiet rng-tools >$NO_OUTPUT
    sudo systemctl start rngd >$NO_OUTPUT
    sudo systemctl enable rngd >$NO_OUTPUT

    _log_success_and_replace "Enabling the Random Number Generator service"

    # ################################################################
    # Enabling DNSSEC support
    # ################################################################

    _log_progress "Enabling DNSSEC support"

    # 'mkdir' can fail if the destination folder already exists
    sudo mkdir --parents /etc/systemd/resolved.conf.d/ || true
    sudo tee /etc/systemd/resolved.conf.d/dnssec.conf >$NO_OUTPUT <<EOT
[Resolve]
DNSSEC=true
EOT

    sudo systemctl restart systemd-resolved

    _log_success_and_replace "Enabling DNSSEC support"

}

03_setup_tpm() {
    _log_title "\n==> Setting up TPM for '${_arg_luks_partition}' auto-decryption"

    # ################################################################
    # Installing prerequisites
    # ################################################################

    _log_progress "Installing prerequisites"

    sudo dnf install --assumeyes --quiet tpm2-tools >$NO_OUTPUT

    _log_success_and_replace "Installing prerequisites"

    # ################################################################
    # Enrolling decryption key in TPM
    # ################################################################

    _log_progress "Enrolling decryption key in TPM"

    sudo systemd-cryptenroll \
        --tpm2-device=auto \
        --tpm2-pcrs=7+8 \
        ${_arg_luks_partition}

    sudo sed --in-place --expression \
        "/^luks-/s/$/,tpm2-device=auto/" \
        /etc/crypttab

    echo 'install_optional_items+=" /usr/lib64/libtss2* /usr/lib64/libfido2.so.* /usr/lib64/cryptsetup/libcryptsetup-token-systemd-tpm2.so "' | sudo tee /etc/dracut.conf.d/tss2.conf >$NO_OUTPUT
    sudo dracut --force

    _log_success "Enrolling decryption key in TPM"
}

04_install_multimedia_codecs() {
    _log_title "\n==> Installing multimedia codecs"

    # ################################################################
    # Installing required sound and audio codecs
    # ################################################################

    _log_progress "Installing required sound and audio codecs"

    sudo dnf config-manager --assumeyes --quiet --set-enable fedora-cisco-openh264 >$NO_OUTPUT

    sudo dnf install --assumeyes --quiet \
        ffmpeg \
        ffmpeg-libs \
        gstreamer1-libav \
        gstreamer1-plugins-{bad-\*,good-\*,base} \
        gstreamer1-plugin-openh264 \
        mozilla-openh264 \
        lame\* \
        --exclude=gstreamer1-plugins-bad-free-devel \
        --exclude=lame-devel >$NO_OUTPUT

    sudo dnf group update --assumeyes --quiet --with-optional multimedia >$NO_OUTPUT

    _log_success_and_replace "Installing required sound and audio codecs"
}

05_install_desktop_theme() {
    _log_title "\n==> Installing desktop theme"

    # ################################################################
    # Configuring desktop settings
    # ################################################################

    _log_progress "Configuring desktop settings"

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

    _log_success_and_replace "Configuring desktop settings"

    # ################################################################
    # Configuring desktop fonts
    # ################################################################

    _log_progress "Configuring desktop fonts"

    sudo dnf install --assumeyes --quiet \
        google-roboto-fonts \
        google-roboto-mono-fonts >$NO_OUTPUT

    gsettings set org.gnome.desktop.interface document-font-name "Roboto 11"
    gsettings set org.gnome.desktop.interface font-name "Roboto 11"
    gsettings set org.gnome.desktop.interface monospace-font-name "Roboto Mono 11"
    gsettings set org.gnome.desktop.wm.preferences titlebar-font "Roboto 11"

    _log_success_and_replace "Configuring desktop fonts"

    # ################################################################
    # Installing shell theme
    # ################################################################

    _log_progress "Installing shell theme"

    sudo dnf install --assumeyes --quiet \
        gtk-murrine-engine \
        gnome-themes-extra \
        gnome-themes-standard \
        sassc >$NO_OUTPUT

    mkdir --parents ~/.themes/_sources/Colloid || true

    cd ~/.themes/_sources/Colloid
    # 'git clone' can fail if the destination folder already exists
    git clone --quiet "https://github.com/vinceliuice/Colloid-gtk-theme.git" shell >$NO_OUTPUT 2>&1 || true
    cd shell

    ./install.sh \
        --color dark \
        --dest "~/.local/share/themes" \
        --theme default \
        --tweaks rimless >$NO_OUTPUT

    gsettings set org.gnome.desktop.interface gtk-theme "Colloid-Dark"
    gsettings set org.gnome.shell.extensions.user-theme name "Colloid-Dark"

    _log_success_and_replace "Installing shell theme"

    # ################################################################
    # Installing icon theme
    # ################################################################

    _log_progress "Installing icon theme"

    cd ~/.themes/_sources/Colloid
    # 'git clone' can fail if the destination folder already exists
    git clone --quiet "https://github.com/vinceliuice/Colloid-icon-theme.git" icons >$NO_OUTPUT 2>&1 || true
    cd icons

    ./install.sh \
        --dest "~/.local/share/icons" \
        --scheme default \
        --theme default >$NO_OUTPUT 2>&1

    gsettings set org.gnome.desktop.interface icon-theme "Colloid"

    _log_success_and_replace "Installing icon theme"

    # ################################################################
    # Installing cursor theme
    # ################################################################

    _log_progress "Installing cursor theme"

    cd ~/.themes/_sources/Colloid
    # 'git clone' can fail if the destination folder already exists
    git clone --quiet "https://github.com/vinceliuice/Colloid-icon-theme.git" cursors >$NO_OUTPUT 2>&1 || true
    cd cursors/cursors

    ./install.sh \
        --dest "~/.local/share/icons" \  >$NO_OUTPUT

    gsettings set org.gnome.desktop.interface cursor-theme "Colloid-cursors"

    _log_success_and_replace "Installing cursor theme"
}

06_install_desktop_extensions() {
    _log_title "\n==> Installing desktop extensions"

    # ################################################################
    # Enabling desktop extensions support
    # ################################################################

    _log_progress "Enabling desktop extensions support"

    sudo dnf install --assumeyes --quiet gnome-tweaks >$NO_OUTPUT
    _install_flatpak "org.gnome.Extensions"

    sudo dnf install --assumeyes --quiet \
        bash \
        curl \
        dbus \
        git \
        less \
        perl >$NO_OUTPUT

    wget --quiet "https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer"
    chmod +x gnome-shell-extension-installer
    sudo mv gnome-shell-extension-installer /usr/bin/

    _log_success_and_replace "Enabling desktop extensions support"

    # ################################################################
    # Installing desktop extensions
    # ################################################################

    _log_progress "Installing desktop extensions"

    cd /usr/share/glib-2.0/schemas
    sudo wget --quiet "https://raw.githubusercontent.com/stuarthayhurst/alphabetical-grid-extension/master/extension/schemas/org.gnome.shell.extensions.AlphabeticalAppGrid.gschema.xml"
    sudo wget --quiet "https://raw.githubusercontent.com/aunetx/blur-my-shell/master/schemas/org.gnome.shell.extensions.blur-my-shell.gschema.xml"
    sudo wget --quiet "https://raw.githubusercontent.com/micheleg/dash-to-dock/master/schemas/org.gnome.shell.extensions.dash-to-dock.gschema.xml"
    sudo wget --quiet "https://gitlab.gnome.org/GNOME/gnome-shell-extensions/-/raw/main/extensions/user-theme/org.gnome.shell.extensions.user-theme.gschema.xml"
    sudo wget --quiet "https://raw.githubusercontent.com/tuxor1337/hidetopbar/master/schemas/org.gnome.shell.extensions.hidetopbar.gschema.xml"
    sudo wget --quiet "https://raw.githubusercontent.com/MartinPL/Tray-Icons-Reloaded/master/schemas/org.gnome.shell.extensions.trayIconsReloaded.gschema.xml"
    sudo glib-compile-schemas . >$NO_OUTPUT 2>&1

    gnome-shell-extension-installer --yes 4269 3193 307 19 545 2890 >$NO_OUTPUT

    _log_success_and_replace "Installing desktop extensions"
}

07_install_terminal_theme() {
    _log_title "\n==> Installing terminal theme"

    # ################################################################
    # Installing shell
    # ################################################################

    _log_progress "Installing shell"

    sudo dnf install --assumeyes --quiet \
        util-linux-user \
        zsh >$NO_OUTPUT

    sudo usermod --shell /bin/zsh $USER >$NO_OUTPUT
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >$NO_OUTPUT 2>&1 || true

    _log_success_and_replace "Installing shell"

    # ################################################################
    # Installing shell theme
    # ################################################################

    _log_progress "Installing shell theme"

    sudo dnf install --assumeyes --quiet dconf >$NO_OUTPUT

    # 'mkdir' can fail if the destination folder already exists
    mkdir --parents ~/.themes/_sources/Monokai || true
    cd ~/.themes/_sources/Monokai

    # 'git clone' can fail if the destination folder already exists
    git clone --quiet "https://github.com/0xComposure/monokai-gnome-terminal" terminal >$NO_OUTPUT 2>&1 || true
    cd terminal
    echo "1\nYES\n" | ./install.sh >$NO_OUTPUT 2>&1 || true

    _log_success_and_replace "Installing shell theme"
}

08_install_applications() {
    _log_title "\n==> Installing applications"

    # ################################################################
    # Installing Bleachbit
    # ################################################################

    _log_progress "Installing Bleachbit"
    sudo dnf install --assumeyes --quiet bleachbit >$NO_OUTPUT
    _log_success_and_replace "Installing Bleachbit"

    # ################################################################
    # Installing Discord
    # ################################################################

    _log_progress "Installing Discord"
    _install_flatpak "com.discordapp.Discord"
    _log_success_and_replace "Installing Discord"

    # ################################################################
    # Installing Flatseal
    # ################################################################

    _log_progress "Installing Flatseal"
    _install_flatpak "com.github.tchx84.Flatseal"
    _log_success_and_replace "Installing Flatseal"

    # ################################################################
    # Installing Mozilla Firefox
    # ################################################################

    _log_progress "Installing Mozilla Firefox"

    # 'killall' fails is there is no process of that name
    sudo killall firefox >$NO_OUTPUT 2>&1 || true
    rm --force --recursive ~/.mozilla

    sudo dnf remove --assumeyes --quiet firefox >$NO_OUTPUT
    _install_flatpak "org.mozilla.firefox"

    _log_success_and_replace "Installing Mozilla Firefox"

    # ################################################################
    # Installing ONLYOFFICE
    # ################################################################

    _log_progress "Installing ONLYOFFICE"
    _install_flatpak "org.onlyoffice.desktopeditors"
    _log_success_and_replace "Installing ONLYOFFICE"

    # ################################################################
    # Installing Visual Studio Code
    # ################################################################

    _log_progress "Installing Visual Studio Code"

    # Using the non-Flatpak version for a better system/terminal integration

    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc >$NO_OUTPUT
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo' >$NO_OUTPUT
    sudo dnf install --assumeyes --quiet code >$NO_OUTPUT

    _log_success_and_replace "Installing Visual Studio Code"

    # ################################################################
    # Installing VLC
    # ################################################################

    _log_progress "Installing VLC"
    _install_flatpak "org.videolan.VLC"
    _log_success_and_replace "Installing VLC"
}

09_install_gaming_requirements() {
    _log_title "\n==> Installing gaming requirements"

    # ################################################################
    # Installing required 32-bit libraries
    # ################################################################

    _log_progress "Installing required 32-bit libraries"

    sudo dnf install --assumeyes --quiet \
        freetype.i686 \
        gnutls.i686 \
        libgpg-error.i686 \
        openldap.i686 \
        pulseaudio-libs.i686 \
        sqlite2.i686 \
        vulkan-loader.i686 >$NO_OUTPUT

    _log_success_and_replace "Installing required 32-bit libraries"

    # ################################################################
    # Installing Lutris
    # ################################################################

    _log_progress "Installing Lutris"
    _install_flatpak "net.lutris.Lutris"
    _log_success_and_replace "Installing Lutris"

    # ################################################################
    # Installing Steam
    # ################################################################

    _log_progress "Installing Steam"
    _install_flatpak "com.valvesoftware.Steam"
    _log_success_and_replace "Installing Steam"
}

10_cleanup() {
    _log_title "\n==> Cleaning up"

    _log_progress "Removing unneeded applications"

    sudo dnf remove --assumeyes --quiet \
        $(rpm --query --all | grep --ignore-case libreoffice) \
        cheese \
        evince \
        gedit \
        gnome-boxes \
        gnome-camera \
        gnome-characters \
        gnome-clocks \
        gnome-connections \
        gnome-contacts \
        gnome-maps \
        gnome-text-editor \
        gnome-tour \
        gnome-weather \
        liveusb-creator \
        rhythmbox \
        totem \
        yelp >$NO_OUTPUT

    _log_success_and_replace "Removing unneeded applications"
}

# --------------------------------
# Main
# --------------------------------

parse_commandline "$@"

set -e

export ECHO_BOLD="\033[1m"
export ECHO_GREEN="\033[1;32m"
export ECHO_GREY="\033[0;37m"
export ECHO_RESET="\033[0m"
export ECHO_REPLACE="\033[1A\033[K"

export NO_OUTPUT="/dev/null"

cat <<"EOT"
    ________________  ____  ____  ___       _____ ______________  ______
   / ____/ ____/ __ \/ __ \/ __ \/   |     / ___// ____/_  __/ / / / __ \
  / /_  / __/ / / / / / / / /_/ / /| |     \__ \/ __/   / / / / / / /_/ /
 / __/ / /___/ /_/ / /_/ / _, _/ ___ |    ___/ / /___  / / / /_/ / ____/
/_/   /_____/_____/\____/_/ |_/_/  |_|   /____/_____/ /_/  \____/_/

EOT

00_update_system

if [ ${_arg_nvidia_drivers} = "on" ]; then
    01_install_nvidia_drivers
fi

02_harden_system

if [ ${_arg_luks_partition} ]; then
    03_setup_tpm
fi

04_install_multimedia_codecs
05_install_desktop_theme
06_install_desktop_extensions
07_install_terminal_theme
08_install_applications
09_install_gaming_requirements
10_cleanup

echo -e "\n[ ${ECHO_BOLD}DONE${ECHO_RESET} ]"
