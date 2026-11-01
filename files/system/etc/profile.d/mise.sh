# Activate mise (https://mise.jdx.dev) system-wide for bash login shells.
# Sourced by /etc/profile via /etc/profile.d; lands in /usr/etc/profile.d at deploy.
if [ -n "${BASH_VERSION:-}" ]; then
    if command -v mise >/dev/null 2>&1; then
        eval "$(mise activate bash)"
    elif [ -x "$HOME/.local/bin/mise" ]; then
        # mise.run installs to ~/.local/bin, which may not be on PATH yet
        eval "$("$HOME/.local/bin/mise" activate bash)"
    fi
fi
