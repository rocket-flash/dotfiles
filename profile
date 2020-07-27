# Set default terminal
export TERMINAL="kitty"

# Get proper date format
export LC_TIME="en_DK.UTF-8"

# Respect XDG Base Directory spec
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export PYENV_ROOT="${XDG_DATA_HOME}/pyenv"
export VAGRANT_HOME="${XDG_DATA_HOME}/vagrant"

# Set JRE for JetBrains products
JETBRAINS_JRE="/usr/lib/jvm/jetbrains-jre"
if [ -d "$JETBRAINS_JRE" ]; then
    export IDEA_JDK="${JETBRAINS_JRE}"    # IntelliJ IDEA
    export CLION_JDK="${JETBRAINS_JRE}"   # CLion
    export PYCHARM_JDK="${JETBRAINS_JRE}" # PyCharm
    export STUDIO_JDK="${JETBRAINS_JRE}"  # AndroidStudio
fi

# Prevent Wine from taking over file associations
# https://wiki.archlinux.org/index.php/wine#Prevent_new_Wine_file_associations
export WINEDLLOVERRIDES="winemenubuilder.exe=d"

# Force hardware acceleration for firefox
export MOZ_USE_OMTC=1

export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1

# Stop here to prevent double adding to PATH and getting out of sync with DE
[[ -n "${PROFILE_SOURCED}" ]] && return

# Go path
export GOPATH="$HOME/usr/go"
[[ -d "$GOPATH/bin" ]] && export PATH="$GOPATH/bin:$PATH"

# Rust's cargo path
export CARGO_HOME="$HOME/usr/cargo"
[[ -d "$CARGO_HOME/bin" ]] && export PATH="$CARGO_HOME/bin:$PATH"

# Personal usr folder
[[ -d "$HOME/usr/bin" ]] && export PATH="$HOME/usr/bin:$PATH"
[[ -d "$HOME/usr/lib" ]] && export LD_LIBRARY_PATH="$HOME/usr/lib:$LD_LIBRARY_PATH"
[[ -d "$HOME/usr/lib/pkgconfig" ]] && export PKG_CONFIG_PATH="$HOME/usr/lib/pkgconfig:$PKG_CONFIG_PATH"

export PROFILE_SOURCED=1

# vim: ft=sh
