#!/bin/sh
set -e

# Installs Meta's Muse Code CLI for the dev container's remote user.
# Runs as root (as every Feature install.sh does). Does not sign in:
# run `muse login` once inside the container.

INSTALLER_URL="https://dev.meta.ai/install.sh"

echo "Activating feature 'muse-code'"

# ---- prerequisites: bash, curl, ca-certificates -------------------------
missing=""
command -v bash >/dev/null 2>&1 || missing="$missing bash"
command -v curl >/dev/null 2>&1 || missing="$missing curl"
[ -e /etc/ssl/certs/ca-certificates.crt ] || [ -e /etc/pki/tls/certs/ca-bundle.crt ] || missing="$missing ca-certificates"

if [ -n "$missing" ]; then
    echo "Installing missing packages:$missing"
    if command -v apt-get >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y
        # shellcheck disable=SC2086
        apt-get install -y --no-install-recommends $missing
        rm -rf /var/lib/apt/lists/*
    elif command -v apk >/dev/null 2>&1; then
        # shellcheck disable=SC2086
        apk add --no-cache $missing
    elif command -v dnf >/dev/null 2>&1; then
        # shellcheck disable=SC2086
        dnf install -y $missing && dnf clean all
    elif command -v microdnf >/dev/null 2>&1; then
        # shellcheck disable=SC2086
        microdnf install -y $missing && microdnf clean all
    elif command -v yum >/dev/null 2>&1; then
        # shellcheck disable=SC2086
        yum install -y $missing && yum clean all
    else
        echo "(!) Could not install:$missing. Install them in your base image first." >&2
        exit 1
    fi
fi

# The Meta installer also needs mktemp, uname, wc, date and sha256sum/shasum.
for cmd in mktemp uname wc date; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "(!) Required command not found: $cmd" >&2
        exit 1
    fi
done
if ! command -v sha256sum >/dev/null 2>&1 && ! command -v shasum >/dev/null 2>&1; then
    echo "(!) sha256sum or shasum is required" >&2
    exit 1
fi

case "$(uname -m)" in
    x86_64|amd64|aarch64|arm64) ;;
    *) echo "(!) Muse Code supports x86_64 and aarch64 Linux only, not $(uname -m)" >&2; exit 1 ;;
esac

# ---- resolve the remote user --------------------------------------------
USERNAME="${_REMOTE_USER:-root}"
if ! id "$USERNAME" >/dev/null 2>&1; then
    echo "(!) Remote user '$USERNAME' does not exist; installing for root instead."
    USERNAME="root"
fi
USER_HOME="${_REMOTE_USER_HOME:-}"
if [ -z "$USER_HOME" ] || [ "$USERNAME" != "${_REMOTE_USER:-root}" ]; then
    USER_HOME="$(awk -F: -v u="$USERNAME" '$1 == u { print $6 }' /etc/passwd)"
fi
if [ -z "$USER_HOME" ]; then
    if [ "$USERNAME" = "root" ]; then USER_HOME="/root"; else USER_HOME="/home/$USERNAME"; fi
fi
USER_GROUP="$(id -gn "$USERNAME")"
INSTALL_DIR="$USER_HOME/.local/bin"

echo "Installing muse for user '$USERNAME' into $INSTALL_DIR"

# ---- run Meta's installer -----------------------------------------------
local_existed=1
[ -d "$USER_HOME/.local" ] || local_existed=0
mkdir -p "$INSTALL_DIR"

tmp_installer="$(mktemp)"
trap 'rm -f "$tmp_installer"' EXIT
curl -fsSL --proto '=https' --tlsv1.2 "$INSTALLER_URL" -o "$tmp_installer"

# MUSE_LOGIN=0: never start the sign-in flow during the build.
# MUSE_NO_MODIFY_PATH=1: PATH is handled below instead of editing shell rc files.
env HOME="$USER_HOME" \
    MUSE_INSTALL_DIR="$INSTALL_DIR" \
    MUSE_LOGIN=0 \
    MUSE_NO_MODIFY_PATH=1 \
    bash "$tmp_installer"

# The installer ran as root; hand the files to the remote user so the
# hourly self-update can write to them.
if [ "$local_existed" = "0" ]; then
    chown -R "$USERNAME:$USER_GROUP" "$USER_HOME/.local"
else
    chown -R "$USERNAME:$USER_GROUP" "$INSTALL_DIR"
fi

# ---- PATH ----------------------------------------------------------------
# Login shells get ~/.local/bin via profile.d. The /usr/local/bin symlink
# covers non-login shells and tools that spawn `muse` directly; the
# launcher follows symlinks back to its own directory.
mkdir -p /etc/profile.d
cat > /etc/profile.d/muse-code.sh <<'PROFILE'
# Added by the muse-code dev container Feature
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
PROFILE
chmod 0644 /etc/profile.d/muse-code.sh

if [ ! -e /usr/local/bin/muse ] || [ -L /usr/local/bin/muse ]; then
    mkdir -p /usr/local/bin
    ln -sf "$INSTALL_DIR/muse" /usr/local/bin/muse
fi

echo "Muse Code CLI installed. Run 'muse login' once inside the container to sign in."
