#!/bin/bash

source common.sh

# ################################################################
# Main
# ################################################################

trap 'handle_errors $LINENO "$BASH_COMMAND"' ERR
sudo echo -e "[ Fedora Workstation Installation Script ]\n"

# ----------------------------------------------------------------

# Installing multimedia codecs
log_step "Installing multimedia codecs"

sudo dnf config-manager --assumeyes --quiet --set-enable fedora-cisco-openh264 >$OUTPUT_EMPTY 2>&1

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

dnf_group_install sound-and-video
dnf_group_update multimedia

# ################################################################
# End
# ################################################################

log_success
