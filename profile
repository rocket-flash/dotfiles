[[ -n "${PROFILE_SOURCED}" ]] && return

# Set default terminal
export TERMINAL="kitty"

# Get proper date format
export LC_TIME="en_DK.UTF-8"

# Force hardware acceleration for firefox
export MOZ_USE_OMTC=1

# Set JDK for JetBrains products
JETBRAINS_JDK="/usr/lib/jvm/intellij-jdk"
if [ -d "$JETBRAINS_JDK" ]; then
    export IDEA_JDK="${JETBRAINS_JDK}"    # IntelliJ IDEA
    export CL_JDK="${JETBRAINS_JDK}"      # CLion
    export PYCHARM_JDK="${JETBRAINS_JDK}" # PyCharm
    export STUDIO_JDK="${JETBRAINS_JDK}"  # AndroidStudio
    export WEBIDE_JDK="${JETBRAINS_JDK}"  # WebStorm
    export RIDER_JDK="${JETBRAINS_JDK}"   # Rider
fi

# Go path
export GOPATH="$HOME/usr/go"

# Rust's cargo path
export CARGO_HOME="$HOME/usr/cargo"
[[ -d "$CARGO_HOME/bin" ]] && export PATH="$CARGO_HOME/bin:$PATH"

# Personal usr folder
[[ -d "$HOME/usr/bin" ]] && export PATH="$HOME/usr/bin:$PATH"
[[ -d "$HOME/usr/lib" ]] && export LD_LIBRARY_PATH="$HOME/usr/lib:$LD_LIBRARY_PATH"
[[ -d "$HOME/usr/lib/pkgconfig" ]] && export PKG_CONFIG_PATH="$HOME/usr/lib/pkgconfig:$PKG_CONFIG_PATH"

# Prevent Wine from taking over file associations
# https://wiki.archlinux.org/index.php/wine#Prevent_new_Wine_file_associations
export WINEDLLOVERRIDES="winemenubuilder.exe=d"

export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1

export PROFILE_SOURCED=1

# vim: ft=sh
