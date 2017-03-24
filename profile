# Set default terminal
export TERMINAL="termite"

# Get proper date format
export LC_TIME="en_DK.UTF-8"

# Force hardware acceleration for firefox
export MOZ_USE_OMTC=1

# Personal usr folder
[[ -d $HOME/usr ]] && export PATH="$HOME/usr/bin:$PATH"

# Prevent Wine from taking over file associations
# https://wiki.archlinux.org/index.php/wine#Prevent_new_Wine_file_associations
export WINEDLLOVERRIDES="winemenubuilder.exe=d"

# vim: ft=sh
