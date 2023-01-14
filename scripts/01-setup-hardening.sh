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

ask_reboot() {
    while true; do
        echo -e "\nA reboot is required to continue. Do you wish to reboot now? [Y/N]"
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

dnf_group_install() {
    sudo dnf group install --assumeyes --quiet $@ >$NO_OUTPUT
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

# ----------------------------------------------------------------
# Enabling kernel self-protection parameters
# ----------------------------------------------------------------

log_progress "Enabling kernel self-protection parameters"

dnf_package_install \
    dracut-live \
    kernel \
    kernel-modules \
    kernel-modules-extra \
    initscripts \
    openssl \
    openssl-libs

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

log_success "Enabling kernel self-protection parameters"

# ----------------------------------------------------------------
# Enabling recommended boot parameters
# ----------------------------------------------------------------

log_progress "Enabling recommended boot parameters"

sudo grubby --update-kernel=ALL --args="debugfs=off init_on_alloc=1 init_on_free=1 lockdown=confidentiality loglevel=0 module.sig_enforce=1 page_alloc.shuffle=1 pti=on randomize_kstack_offset=on slab_nomerge spectre_v2=on spec_store_bypass_disable=on tsx=off tsx_async_abort=full,nosmt mds=full,nosmt l1tf=full,force nosmt=force kvm.nx_huge_pages=force vsyscall=none"

# Details:
#   - `debugfs=off`: removes sensitive kernel information during boot.
#   - `init_on_alloc=1 init_on_free=1`: mitigates use-after-free vulnerabilities and erases sensitive information in memory.
#   - `lockdown=confidentiality`: reduces kernel privileges escalation methods via user space (implies `module.sig_enforce=1`).
#   - `loglevel=0`: prevents information leaks during boot (implies `quiet` on boot, and `kernel.kptr_restrict=2` on sysctl.conf).
#   - `module.sig_enforce=1`: only allows kernel modules that have been signed with a valid key.
#   - `page_alloc.shuffle=1`: improves security by making page allocations less predictable, and improves performance.
#   - `pti=on`: mitigates Meltdown and prevents some KASLR bypasses.
#   - `randomize_kstack_offset=on`: reduces attacks that rely on deterministic kernel stack layout.
#   - `slab_nomerge`: prevents overwriting objects from merged caches.
#   - `spectre_v2=on spec_store_bypass_disable=on tsx=off tsx_async_abort=full,nosmt mds=full,nosmt l1tf=full,force nosmt=force kvm.nx_huge_pages=force`: enables all built-in mitigations for all known CPU vulnerabilities (microcode updates should be installed to reduce performance impact).
#   - `vsyscall=none`: disables vsyscalls (obsolete, and replaced by vDSO).

log_success "Enabling recommended boot parameters"

# ----------------------------------------------------------------
# Enabling the Random Number Generator service
# ----------------------------------------------------------------

log_progress "Enabling the Random Number Generator service"

dnf_package_install rng-tools

sudo systemctl start rngd >$NO_OUTPUT
sudo systemctl enable rngd >$NO_OUTPUT

log_success "Enabling the Random Number Generator service"

# ----------------------------------------------------------------
# Enabling DNSSEC support
# ----------------------------------------------------------------

log_progress "Enabling DNSSEC support"

# 'mkdir' fails if the destination folder already exists
sudo mkdir --parents /etc/systemd/resolved.conf.d/ || true

sudo tee /etc/systemd/resolved.conf.d/dnssec.conf >$NO_OUTPUT <<EOT
[Resolve]
DNSSEC=true
EOT

sudo systemctl restart systemd-resolved

log_success "Enabling DNSSEC support"

# ################################################################
# REBOOT
# ################################################################

echo -e "\n[ ${ECHO_BOLD}OK${ECHO_RESET} ]"

ask_reboot
