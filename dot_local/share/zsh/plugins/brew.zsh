if ! installed brew; then
    return
fi

BREW_PREFIX="$(brew --prefix)"
export PATH="$PATH:${BREW_PREFIX}/sbin"

# GNU utilities
for pkg in "coreutils" "findutils" "gnu-sed"; do
    gnubin="${BREW_PREFIX}/opt/${pkg}/libexec/gnubin"
    [[ -d "${gnubin}" ]] && export PATH="${gnubin}:${PATH}"
done

# Lib specific flags
for lib in 'openssl' 'zlib'; do
    lib_path="${BREW_PREFIX}/opt/${lib}"
    if [[ -d "${lib_path}" ]]; then
        export LDFLAGS="$LDFLAGS -L${lib_path}/lib"
        export CFLAGS="$CFLAGS -I${lib_path}/include"
        export PKG_CONFIG_PATH="${lib_path}/lib/pkgconfig:$PKG_CONFIG_PATH"
    fi
done

# Qt
QT_PATH="${BREW_PREFIX}/opt/qt"
if [[ -d "${QT_PATH}" ]]; then
    export CMAKE_PREFIX_PATH="${QT_PATH}:$CMAKE_PREFIX_PATH"
    export PATH="$PATH:${QT_PATH}/bin"
fi
