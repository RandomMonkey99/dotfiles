#!/usr/bin/env bash

ACTION=$(printf "Install\nRemove\nUpdate All\nSearch\nList Installed" | rofi \
    -dmenu \
    -i \
    -p "Packages" \
    -theme ~/.config/rofi/network.rasi)

[[ -z "$ACTION" ]] && exit 0

case "$ACTION" in
    "Install")
        PKG=$(rofi -dmenu -i -p "Install" \
            -theme ~/.config/rofi/network.rasi \
            < /dev/null)
        [[ -z "$PKG" ]] && exit 0
        kitty --hold bash -c "yay -S $PKG"
        ;;

    "Remove")
        PKG=$(yay -Qq | rofi \
            -dmenu \
            -i \
            -p "Remove" \
            -theme ~/.config/rofi/network.rasi)
        [[ -z "$PKG" ]] && exit 0
        kitty --hold bash -c "yay -Rns $PKG"
        ;;

    "Update All")
        kitty --hold bash -c "yay -Syu"
        ;;

    "Search")
        QUERY=$(rofi -dmenu -i -p "Search" \
            -theme ~/.config/rofi/network.rasi \
            < /dev/null)
        [[ -z "$QUERY" ]] && exit 0
        RESULT=$(yay -Ss "$QUERY" | grep -E "^[^ ]" | awk '{print $1}' | rofi \
            -dmenu \
            -i \
            -p "Install" \
            -theme ~/.config/rofi/network.rasi)
        [[ -z "$RESULT" ]] && exit 0
        kitty --hold bash -c "yay -S $RESULT"
        ;;

    "List Installed")
        PKG=$(yay -Qq | rofi \
            -dmenu \
            -i \
            -p "Installed" \
            -theme ~/.config/rofi/network.rasi)
        [[ -z "$PKG" ]] && exit 0
        kitty --hold bash -c "yay -Qi $PKG"
        ;;
esac