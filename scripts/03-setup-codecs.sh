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

log_progress "Installing multimedia codecs"

sudo dnf config-manager --assumeyes --quiet --set-enable fedora-cisco-openh264 >$NO_OUTPUT 2>&1

dnf_package_install \
    ffmpeg \
    ffmpeg-libs \
    ffmpeg-libs.i686 \
    flac-libs \
    flac-libs.i686 \
    gstreamer1 \
    gstreamer1-libav \
    gstreamer1-plugin-openh264 \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-bad-free.i686 \
    gstreamer1-plugins-base \
    gstreamer1-plugins-base.i686 \
    gstreamer1-plugins-good \
    gstreamer1-plugins-good.i686 \
    gstreamer1-plugins-ugly-free \
    gstreamer1-plugins-ugly-free.i686 \
    gstreamer1-vaapi \
    gstreamer1.i686 \
    lame\* \
    libaom \
    libaom.i686 \
    libasyncns \
    libasyncns.i686 \
    libavdevice \
    libavdevice.i686 \
    libexif \
    libexif.i686 \
    libfreeaptx \
    libsndfile \
    libsndfile.i686 \
    libva \
    libva-utils \
    libva.i686 \
    libvorbis \
    libvorbis.i686 \
    mozilla-openh264 \
    pipewire-codec-aptx \
    pulseaudio-libs \
    pulseaudio-libs.i686 \
    x264-libs \
    x264-libs.i686 \
    x265-libs \
    x265-libs.i686 \
    --exclude=gstreamer1-plugins-bad-free-devel \
    --exclude=lame-devel

dnf_group_update multimedia
dnf_group_update sound-and-video

log_success "Installing multimedia codecs"
