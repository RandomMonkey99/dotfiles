#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/hypr/walls/"
THUMBNAIL_DIR="$HOME/.cache/wall_thumbs"
mkdir -p "$THUMBNAIL_DIR"

declare -A WALL_NAMES=(
    ["forest.png"]="󱢗 Forest"
    ["megacity.png"]="󰅆 Megacity"
    ["streetlights.png"]="󱁀 Streetlights"
    ["valley.png"]="⛰ Valley"
    ["waterfall.png"]="󱡉 Waterfall"
)

MAPFILE=$(mktemp)
entries=""

for img in "$WALLPAPER_DIR"/*; do
    [[ -f "$img" ]] || continue
    [[ "$img" =~ \.(jpg|jpeg|png|webp)$ ]] || continue
    fname=$(basename "$img")
    thumb="$THUMBNAIL_DIR/$fname"
    [[ -f "$thumb" ]] || magick "$img" -thumbnail 500x300^ -gravity center -extent 500x300 "$thumb"
    label="${WALL_NAMES[$fname]:-${fname%.*}}"
    echo "${label}|${fname}" >> "$MAPFILE"
    entries+="${label}\0icon\x1f${thumb}\n"
done

entries="${entries%\\n}"

chosen=$(printf "%b" "$entries" | rofi \
    -dmenu \
    -i \
    -p "" \
    -show-icons \
    -theme ~/.config/rofi/network.rasi \
    -theme-str 'window { width: 90%; location: south; anchor: south; y-offset: 60px; }' \
    -theme-str 'mainbox { orientation: vertical; }' \
    -theme-str 'listview { layout: horizontal; scrolling: horizontal; columns: 9999; lines: 7; spacing: 10px; padding: 10px; }' \
    -theme-str 'element { orientation: vertical; children: [ element-icon, element-text ]; padding: 6px; }' \
    -theme-str 'element selected { background-color: transparent; border: 2px solid; border-color: @accent; }' \
    -theme-str 'element-icon { size: 200px; }' \
    -theme-str 'element-icon selected { background-color: transparent; }' \
    -theme-str 'element-text { horizontal-align: 0.5; vertical-align: 0.5; padding: 4px 0px 0px 0px; }' \
    -theme-str 'inputbar { enabled: false; }')

[[ -z "$chosen" ]] && { rm "$MAPFILE"; exit 0; }

fname=$(grep "^${chosen}|" "$MAPFILE" | cut -d'|' -f2)
rm "$MAPFILE"

[[ -z "$fname" ]] && exit 1

awww img "$WALLPAPER_DIR/$fname" --transition-type center
awww img -o HDMI-A-1 "$WALLPAPER_DIR/$fname" --transition-type center