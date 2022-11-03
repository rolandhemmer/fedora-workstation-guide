#!/bin/bash
#
# Generated using Argbash v2.9.0
# See https://argbash.io for more
#

# --------------------------------
# Arguments Parsing and Management
# --------------------------------

_positionals=()

_arg_luks_partition=
_arg_nvidia_drivers="off"

assign_positional_args() {
    local _positional_name _shift_for=$1
    _positional_names="_arg_static_hostname _arg_pretty_hostname "

    shift "$_shift_for"
    for _positional_name in ${_positional_names}; do
        test $# -gt 0 || break
        eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
        shift
    done
}

begins_with_short_option() {
    local first_option all_short_options='lnh'
    first_option="${1:0:1}"
    test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

die() {
    local _ret="${2:-1}"
    test "${_PRINT_HELP:-no}" = yes && print_help >&2
    echo -e "[ ${ECHO_RED}KO${ECHO_RESET} ]\t$1" >&2
    exit "${_ret}"
}

handle_passed_args_count() {
    local _required_args_string="'static-hostname' and 'pretty-hostname'"
    test "${_positionals_count}" -ge 2 || _PRINT_HELP=yes die "Not enough arguments - exactly 2 required (namely: $_required_args_string), only got ${_positionals_count}" 1
    test "${_positionals_count}" -le 2 || _PRINT_HELP=yes die "Too many arguments - exactly 2 required (namely: $_required_args_string), got ${_positionals_count} (last one was: '${_last_positional}')" 1
}

parse_commandline() {
    _positionals_count=0
    while test $# -gt 0; do
        _key="$1"
        case "$_key" in
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
        -h | --help)
            print_help
            exit 0
            ;;
        -h*)
            print_help
            exit 0
            ;;
        *)
            _last_positional="$1"
            _positionals+=("$_last_positional")
            _positionals_count=$((_positionals_count + 1))
            ;;
        esac
        shift
    done
}

print_help() {
    printf '%s\n\n' "Fedora Workstation Personal Installation Script (1/2)"
    printf 'Usage: %s <static-hostname> <pretty-hostname> [-l|--luks-partition <arg>] [-n|--nvidia-drivers] [-h|--help]\n' "$0"
    printf '\t%s\t%s\t%s\n' "<static-hostname>" "Static name of the system, containing only lowercase letters, numbers and/or dashes" "(e.g: \"system-name-01\")"
    printf '\t%s\t%s\t\t\t\t\t\t%s\n' "<pretty-hostname>" "Pretty name of the system, without restrictions" "(e.g: \"System Name 01\")"
    printf '\t%s\t%s\t%s\n' "-l, --luks-partition" "Partition name of the LUKS container to be automatically decrypted using the TPM chip" "(e.g: /dev/sda1)"
    printf '\t%s\t%s\n' "-n, --nvidia-drivers" "Includes latest Nvidia drivers with installation"
    printf '\t%s\t\t%s\n' "-h, --help" "Prints help"
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

00_setup_prerequisites() {
    # ################################################################
    # Configuring hostname
    # ################################################################

    __log_progress__ "Configuring hostname"

    sudo hostnamectl set-hostname --pretty $_arg_pretty_hostname
    sudo hostnamectl set-hostname --static $_arg_static_hostname

    __log_success__ "Configuring hostname"

    # ################################################################
    # Configuring Git settings
    # ################################################################

    __log_progress__ "Configuring Git settings"

    git config --global commit.gpgsign true
    git config --global core.autocrlf input
    git config --global core.editor vim
    git config --global core.eol lf
    git config --global diff.colormoved zebra
    git config --global fetch.prune true
    git config --global http.maxrequestbuffer 128M
    git config --global http.postbuffer 512M
    git config --global pull.rebase true
    git config --global submodule.recurse true

    __log_success__ "Configuring Git settings"
}

01_update_system() {
    __log_title__ "\n==> Updating system"

    # ################################################################
    # Updating DNF settings
    # ################################################################

    __log_progress__ "Updating DNF settings"
    sudo tee --append /etc/dnf/dnf.conf >$NO_OUTPUT <<EOT
deltarpm=true
fastestmirror=1
max_parallel_downloads=20
EOT
    __log_success__ "Updating DNF settings"

    # ################################################################
    # Enabling Flatpak repositories
    # ################################################################

    __log_progress__ "Enabling Flatpak repositories"

    flatpak remote-add --if-not-exists --user fedora oci+https://registry.fedoraproject.org
    flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo

    __log_success__ "Enabling Flatpak repositories"

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
    # Enabling the Fedora RPM Fusion repositories
    # ################################################################

    __log_progress__ "Enabling the Fedora RPM Fusion repositories"

    __install_dnf__ https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm --eval %fedora).noarch.rpm
    __install_dnf__ https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm --eval %fedora).noarch.rpm

    __install_dnf__ \
        fedora-workstation-repositories \
        rpmfusion-free-appstream-data \
        rpmfusion-nonfree-appstream-data >$NO_OUTPUT

    sudo dnf group update core --assumeyes --quiet >$NO_OUTPUT

    __log_success__ "Enabling the Fedora RPM Fusion repositories"

    # ################################################################
    # Performing a full system upgrade
    # ################################################################

    __log_progress__ "Performing a full system upgrade"

    sudo dnf clean --assumeyes --quiet all >$NO_OUTPUT
    sudo dnf upgrade --assumeyes --quiet --refresh >$NO_OUTPUT
    __install_dnf__ neofetch

    __log_success__ "Performing a full system upgrade"

    # ################################################################
    # Updating system drivers
    # ################################################################

    __log_progress__ "Updating system drivers"

    __install_dnf__ fwupd

    # The 'fwupdmgr' command exits with '1' (as failure) when no update is needed
    sudo fwupdmgr --assume-yes --force refresh >$NO_OUTPUT 2>&1 || true
    sudo fwupdmgr --assume-yes --force get-updates >$NO_OUTPUT 2>&1 || true

    __log_success__ "Updating system drivers"

    # ################################################################
    # Installing Preload
    # ################################################################

    __log_progress__ "Installing Preload"

    sudo dnf copr enable --assumeyes elxreno/preload >$NO_OUTPUT 2>&1
    __install_dnf__ preload
    sudo systemctl start preload >$NO_OUTPUT
    sudo systemctl enable preload >$NO_OUTPUT

    __log_success__ "Installing Preload"
}

02_install_nvidia_drivers() {
    __log_title__ "\n==> Installing latest Nvidia drivers"

    # ################################################################
    # Installing prerequisites
    # ################################################################

    __log_progress__ "Installing prerequisites"

    __install_dnf__ \
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
        wget

    __log_success__ "Installing prerequisites"

    # ################################################################
    # Enabling Nvidia kernel module auto-signing
    # ################################################################

    __log_progress__ "Enabling Nvidia kernel module auto-signing"

    sudo kmodgenca --auto
    sudo mokutil --import /etc/pki/akmods/certs/public_key.der

    __log_success_alt__ "Enabling Nvidia kernel module auto-signing"

    # ################################################################
    # Installing latest Nvidia drivers
    # ################################################################

    __log_progress__ "Installing latest Nvidia drivers"

    sudo dnf config-manager --set-enable rpmfusion-nonfree-nvidia-driver >$NO_OUTPUT

    __install_dnf__ \
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
        vulkan-loader.i686

    echo "%global _with_kmod_nvidia_open 1" | sudo tee /etc/rpm/macros-nvidia-kmod >$NO_OUTPUT
    sudo akmods --force >$NO_OUTPUT
    sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1' >$NO_OUTPUT

    echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >$NO_OUTPUT
    echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist.conf >$NO_OUTPUT

    sudo tee /etc/dracut.conf.d/nvidia.conf >$NO_OUTPUT <<EOT
add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "
install_items+=" /etc/modprobe.d/nvidia.conf "
EOT

    sudo dracut --force

    __log_success__ "Installing latest Nvidia drivers"
}

03_harden_system() {
    __log_title__ "\n==> Hardening system"

    # ################################################################
    # Enabling kernel self-protection parameters
    # ################################################################

    __log_progress__ "Enabling kernel self-protection parameters"

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

    __log_success__ "Enabling kernel self-protection parameters"

    # ################################################################
    # Enabling recommended boot parameters
    # ################################################################

    __log_progress__ "Enabling recommended boot parameters"

    sudo grubby --update-kernel=ALL --args="debugfs=off init_on_alloc=1 init_on_free=1 lockdown=confidentiality loglevel=0 module.sig_enforce=1 page_alloc.shuffle=1 pti=on randomize_kstack_offset=on slab_nomerge spectre_v2=on spec_store_bypass_disable=on tsx=off tsx_async_abort=full,nosmt mds=full,nosmt l1tf=full,force nosmt=force kvm.nx_huge_pages=force vsyscall=none"

    __log_success__ "Enabling recommended boot parameters"

    # ################################################################
    # Enabling the Random Number Generator service
    # ################################################################

    __log_progress__ "Enabling the Random Number Generator service"

    __install_dnf__ rng-tools
    sudo systemctl start rngd >$NO_OUTPUT
    sudo systemctl enable rngd >$NO_OUTPUT

    __log_success__ "Enabling the Random Number Generator service"

    # ################################################################
    # Enabling DNSSEC support
    # ################################################################

    __log_progress__ "Enabling DNSSEC support"

    # 'mkdir' fails if the destination folder already exists
    sudo mkdir --parents /etc/systemd/resolved.conf.d/ || true
    sudo tee /etc/systemd/resolved.conf.d/dnssec.conf >$NO_OUTPUT <<EOT
[Resolve]
DNSSEC=true
EOT

    sudo systemctl restart systemd-resolved

    __log_success__ "Enabling DNSSEC support"

}

04_setup_tpm() {
    __log_title__ "\n==> Setting up TPM for '${_arg_luks_partition}' auto-decryption"

    # ################################################################
    # Installing prerequisites
    # ################################################################

    __log_progress__ "Installing prerequisites"
    __install_dnf__ tpm2-tools
    __log_success__ "Installing prerequisites"

    # ################################################################
    # Enrolling decryption key in TPM
    # ################################################################

    __log_progress__ "Enrolling decryption key in TPM"

    sudo systemd-cryptenroll \
        --tpm2-device=auto \
        --tpm2-pcrs=7+8 \
        ${_arg_luks_partition}

    sudo sed --in-place --expression \
        "/^luks-/s/$/,tpm2-device=auto/" \
        /etc/crypttab

    echo 'install_optional_items+=" /usr/lib64/libtss2* /usr/lib64/libfido2.so.* /usr/lib64/cryptsetup/libcryptsetup-token-systemd-tpm2.so "' | sudo tee /etc/dracut.conf.d/tss2.conf >$NO_OUTPUT

    sudo dracut --force

    __log_success_alt__ "Enrolling decryption key in TPM"
}

05_install_multimedia_codecs() {
    __log_title__ "\n==> Installing multimedia codecs"

    # ################################################################
    # Installing required sound and audio codecs
    # ################################################################

    __log_progress__ "Installing required sound and audio codecs"

    sudo dnf config-manager --assumeyes --quiet --set-enable fedora-cisco-openh264 >$NO_OUTPUT

    __install_dnf__ \
        ffmpeg \
        ffmpeg-libs \
        gstreamer1-libav \
        gstreamer1-plugins-{bad-\*,good-\*,base} \
        gstreamer1-plugin-openh264 \
        mozilla-openh264 \
        lame\* \
        --exclude=gstreamer1-plugins-bad-free-devel \
        --exclude=lame-devel

    sudo dnf group update --assumeyes --quiet --with-optional multimedia >$NO_OUTPUT

    __log_success__ "Installing required sound and audio codecs"
}

06_install_desktop_theme() {
    __log_title__ "\n==> Installing desktop theme"

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

    __install_dnf__ \
        google-roboto-fonts \
        google-roboto-mono-fonts >$NO_OUTPUT

    gsettings set org.gnome.desktop.interface document-font-name "Roboto 11"
    gsettings set org.gnome.desktop.interface font-name "Roboto 11"
    gsettings set org.gnome.desktop.interface monospace-font-name "Roboto Mono 11"
    gsettings set org.gnome.desktop.wm.preferences titlebar-font "Roboto 11"

    sudo fc-cache --really-force

    __log_success__ "Configuring desktop fonts"

    # ################################################################
    # Installing shell theme
    # ################################################################

    __log_progress__ "Installing shell theme"

    mkdir --parents ~/.gnome/sources/themes || true
    mkdir --parents ~/.gnome/sources/icons || true
    mkdir --parents ~/.gnome/sources/cursors || true

    __install_dnf__ \
        gtk-murrine-engine \
        gnome-themes-extra \
        gnome-themes-standard \
        sassc

    cd ~/.gnome/sources/themes
    # 'git clone' can fail if the destination folder already exists
    git clone --quiet "https://github.com/vinceliuice/Colloid-gtk-theme.git" Colloid >$NO_OUTPUT 2>&1 || true
    cd Colloid

    sudo ./install.sh \
        --color dark \
        --theme default \
        --tweaks rimless >$NO_OUTPUT 2>&1

    gsettings set org.gnome.desktop.interface gtk-theme "Colloid-Dark"

    __log_success__ "Installing shell theme"

    # ################################################################
    # Installing icon theme
    # ################################################################

    __log_progress__ "Installing icon theme"

    cd ~/.gnome/sources/icons
    # 'git clone' can fail if the destination folder already exists
    git clone --quiet "https://github.com/vinceliuice/Colloid-icon-theme.git" Colloid >$NO_OUTPUT 2>&1 || true
    cd Colloid

    sudo ./install.sh \
        --scheme default \
        --theme default >$NO_OUTPUT 2>&1

    gsettings set org.gnome.desktop.interface icon-theme "Colloid-dark"

    __log_success__ "Installing icon theme"

    # ################################################################
    # Installing cursor theme
    # ################################################################

    __log_progress__ "Installing cursor theme"

    cd ~/.gnome/sources/cursors
    # 'git clone' can fail if the destination folder already exists
    git clone --quiet "https://github.com/vinceliuice/Colloid-icon-theme.git" Colloid >$NO_OUTPUT 2>&1 || true
    cd Colloid/cursors

    sudo ./install.sh >$NO_OUTPUT 2>&1

    gsettings set org.gnome.desktop.interface cursor-theme "Colloid-cursors"

    __log_success__ "Installing cursor theme"
}

07_install_desktop_extensions() {
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

    wget --quiet "https://raw.githubusercontent.com/brunelli/gnome-shell-extension-installer/master/gnome-shell-extension-installer"
    chmod +x gnome-shell-extension-installer
    sudo mv gnome-shell-extension-installer /usr/bin/

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

08_install_terminal_options() {
    __log_title__ "\n==> Installing terminal options"

    # ################################################################
    # Installing terminal shell
    # ################################################################

    __log_progress__ "Installing terminal shell"

    __install_dnf__ \
        util-linux-user \
        zsh

    sudo usermod --shell /bin/zsh $USER >$NO_OUTPUT
    echo "Y\n" | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >$NO_OUTPUT || true

    __log_success__ "Installing terminal shell"
}

09_install_applications() {
    __log_title__ "\n==> Installing applications"

    # ################################################################
    # Installing Bleachbit
    # ################################################################

    __log_progress__ "Installing Bleachbit"
    __install_dnf__ bleachbit
    __log_success__ "Installing Bleachbit"

    # ################################################################
    # Installing Discord
    # ################################################################

    __log_progress__ "Installing Discord"
    __install_flatpak__ "com.discordapp.Discord"
    __log_success__ "Installing Discord"

    # ################################################################
    # Installing Fedora Media Writer
    # ################################################################

    __log_progress__ "Installing Fedora Media Writer"

    # 'killall' fails is there is no process of that name
    sudo killall liveusb-creator >$NO_OUTPUT 2>&1 || true
    sudo dnf remove --assumeyes --quiet liveusb-creator >$NO_OUTPUT

    __install_flatpak__ "org.fedoraproject.MediaWriter"

    __log_success__ "Installing Fedora Media Writer"

    # ################################################################
    # Installing Flatseal
    # ################################################################

    __log_progress__ "Installing Flatseal"
    __install_flatpak__ "com.github.tchx84.Flatseal"
    __log_success__ "Installing Flatseal"

    # ################################################################
    # Installing Fragments
    # ################################################################

    __log_progress__ "Installing Fragments"
    __install_flatpak__ "de.haeckerfelix.Fragments"
    __log_success__ "Installing Fragments"

    # ################################################################
    # Installing Mozilla Firefox
    # ################################################################

    __log_progress__ "Installing Mozilla Firefox"

    # 'killall' fails is there is no process of that name
    sudo killall firefox >$NO_OUTPUT 2>&1 || true
    sudo dnf remove --assumeyes --quiet firefox >$NO_OUTPUT
    rm --force --recursive ~/.mozilla

    __install_flatpak__ "org.mozilla.firefox"

    __log_success__ "Installing Mozilla Firefox"

    # ################################################################
    # Installing ONLYOFFICE
    # ################################################################

    __log_progress__ "Installing ONLYOFFICE"
    __install_flatpak__ "org.onlyoffice.desktopeditors"
    __log_success__ "Installing ONLYOFFICE"

    # ################################################################
    # Installing Visual Studio Codium
    # ################################################################

    __log_progress__ "Installing Visual Studio Codium"

    # Using the non-Flatpak version for a better system/terminal integration

    sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg >$NO_OUTPUT
    printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee /etc/yum.repos.d/vscodium.repo >$NO_OUTPUT

    __install_dnf__ codium

    __log_success__ "Installing Visual Studio Codium"

    # ################################################################
    # Installing VLC
    # ################################################################

    __log_progress__ "Installing VLC"
    __install_flatpak__ "org.videolan.VLC"
    __log_success__ "Installing VLC"
}

10_install_gaming_features() {
    __log_title__ "\n==> Installing gaming features"

    # ################################################################
    # Installing Bottles
    # ################################################################

    __log_progress__ "Installing Bottles"
    __install_flatpak__ "com.usebottles.bottles"
    __log_success__ "Installing Bottles"

    # ################################################################
    # Installing Steam
    # ################################################################

    __log_progress__ "Installing Steam"
    __install_flatpak__ "com.valvesoftware.Steam"
    __log_success__ "Installing Steam"
}

11_install_automation_scripts() {
    __log_title__ "\n==> Installing automation scripts"

    # ################################################################
    # Installing update script
    # ################################################################

    __log_progress__ "Installing update script"
    sudo mv scripts/update.sh /usr/bin/update
    __log_success__ "Installing update script"

}

12_cleanup() {
    __log_title__ "\n==> Cleaning up"

    __log_progress__ "Removing unneeded applications"

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
        gnome-photos \
        gnome-text-editor \
        gnome-tour \
        gnome-weather \
        rhythmbox \
        totem \
        yelp >$NO_OUTPUT

    __log_success__ "Removing unneeded applications"
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
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"

set -e
sudo echo ""

cat <<"EOT"
    ________________  ____  ____  ___       _____ ______________  ______
   / ____/ ____/ __ \/ __ \/ __ \/   |     / ___// ____/_  __/ / / / __ \
  / /_  / __/ / / / / / / / /_/ / /| |     \__ \/ __/   / / / / / / /_/ /
 / __/ / /___/ /_/ / /_/ / _, _/ ___ |    ___/ / /___  / / / /_/ / ____/
/_/   /_____/_____/\____/_/ |_/_/  |_|   /____/_____/ /_/  \____/_/

EOT

00_setup_prerequisites
01_update_system

if [ ${_arg_nvidia_drivers} = "on" ]; then
    02_install_nvidia_drivers
fi

03_harden_system

if [ ${_arg_luks_partition} ]; then
    04_setup_tpm
fi

05_install_multimedia_codecs
06_install_desktop_theme
07_install_desktop_extensions
08_install_terminal_options
09_install_applications
10_install_gaming_features
11_install_automation_scripts
12_cleanup

echo -e "\n[ ${ECHO_BOLD}OK${ECHO_RESET} ]"
