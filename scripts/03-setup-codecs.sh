#!/bin/bash

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
# BASE METHODS
# ################################################################

dnf_group_update() {
    sudo dnf group update --assumeyes --quiet --with-optional $@ >$NO_OUTPUT
}

dnf_package_install() {
    sudo dnf install --assumeyes --quiet $@ >$NO_OUTPUT
}

# ################################################################
# MAIN
# ################################################################

trap 'handle_errors $LINENO' ERR
sudo echo ""

cat <<"EOT"
    ________________  ____  ____  ___       _____ ______________  ______
   / ____/ ____/ __ \/ __ \/ __ \/   |     / ___// ____/_  __/ / / / __ \
  / /_  / __/ / / / / / / / /_/ / /| |     \__ \/ __/   / / / / / / /_/ /
 / __/ / /___/ /_/ / /_/ / _, _/ ___ |    ___/ / /___  / / / /_/ / ____/
/_/   /_____/_____/\____/_/ |_/_/  |_|   /____/_____/ /_/  \____/_/

EOT

log_progress "Installing multimedia codecs"

sudo dnf config-manager --assumeyes --quiet --set-enable fedora-cisco-openh264 >$NO_OUTPUT

dnf_package_install \
    ffmpeg \
    ffmpeg-libs \
    flac-libs \
    gstreamer1 \
    gstreamer1-libav \
    gstreamer1-plugin-openh264 \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-base \
    gstreamer1-plugins-good \
    gstreamer1-plugins-ugly-free \
    gstreamer1-vaapi \
    lame\* \
    libaom \
    libasyncns \
    libavdevice \
    libexif \
    libfreeaptx \
    libsndfile \
    libvorbis \
    mozilla-openh264 \
    pipewire-codec-aptx \
    x264-libs \
    x265-libs \
    --exclude=gstreamer1-plugins-bad-free-devel \
    --exclude=lame-devel

dnf_group_update multimedia
dnf_group_update sound-and-video

log_success "Installing multimedia codecs"
