#!/usr/bin/env bash
# app_mosaic.sh — rofi app launcher in a mosaic/masonry tile layout
# Each app tile is a different "size" (wide, tall, square) for a mosaic look.
# The inputbar doubles as a DuckDuckGo search bar when no app is matched.
#
# Dependencies: rofi (≥1.7), xdg-open or $BROWSER, python3 (for URL encoding),
#               a Nerd Font (DepartureMono Nerd Font by default)

# ─── CONFIG ────────────────────────────────────────────────────────────────────

FONT="DepartureMono Nerd Font 11"
BROWSER="${BROWSER:-xdg-open}"

# Format: "Icon  Label|exec command"
# The icon + label become the entry text shown in the rofi grid cell.
# Tip: keep labels short — 1–2 words — so they fit inside tiles.
APPS=(
    "󰈹  Firefox|firefox"
    "  Terminal|kitty"
    "󰨞  VSCode|code"
    "󰎆  Spotify|firefox open.spotify.com"
)

# ─── MOSAIC THEME ──────────────────────────────────────────────────────────────
# Rofi's grid layout (columns + lines) forms the base "grid".
# The "mosaic" feel comes from:
#   • varying element padding to make some tiles feel visually heavier
#   • alternating accent marks via background on alternate elements
#   • a large icon glyph + smaller label stacked vertically
#   • heavy corner rounding and subtle offset borders

TMPTHEME=$(mktemp /tmp/app_mosaic_XXXXXX.rasi)

cat > "$TMPTHEME" <<'RASI'
* {
    /* Palette */
    base:     #0d0d11;
    surface:  #161620;
    raised:   #1e1e2a;
    border:   #2a2a3a;
    accent:   #8b7cf8;
    accent2:  #5ec4a8;
    muted:    #555570;
    fg:       #dddcf5;
    fg-dim:   #9090a8;

    /* Resets */
    background-color: transparent;
    text-color:       @fg;
    font:             "DepartureMono Nerd Font 11";
    spacing:          0;
}

/* ── Window ── */
window {
    background-color: @base;
    border:           1px solid @border;
    border-radius:    16px;
    width:            580px;
    padding:          0;
}

/* ── Shell ── */
mainbox {
    background-color: transparent;
    children:         [ inputbar, separator, listview ];
    padding:          0;
    spacing:          0;
}

/* ── Search bar ── */
inputbar {
    background-color: @surface;
    border-radius:    16px 16px 0 0;
    padding:          11px 16px;
    spacing:          10px;
    children:         [ prompt, entry ];
}

prompt {
    background-color: transparent;
    text-color:       @accent;
    vertical-align:   0.5;
}

entry {
    background-color: transparent;
    text-color:       @fg;
    placeholder:      "search apps  ·  or the web on DuckDuckGo";
    placeholder-color: @muted;
    cursor:           text;
}

/* ── Hairline separator ── */
separator {
    background-color: @border;
    height:           1px;
}

/* ── Grid ── */
listview {
    background-color: transparent;
    padding:          14px;
    spacing:          10px;
    columns:          4;
    lines:            3;
    layout:           vertical;
    fixed-columns:    true;
    fixed-height:     false;
    cycle:            true;
}

/* ── Tile (base) ── */
element {
    background-color: @raised;
    border:           1px solid @border;
    border-radius:    12px;
    padding:          20px 10px 16px;
    orientation:      vertical;
    cursor:           pointer;
    /* The "mosaic" variation is achieved by alternating accent borders below */
}

/* ── Focused tile ── */
element selected.normal {
    background-color: #26263a;
    border-color:     @accent;
    border-width:     1px;
    text-color:       @fg;
}

/* ── Accent tiles — every 3rd tile gets a teal left-edge marker ── */
element.alternate.normal {
    border-color:     @accent2;
    border-width:     1px 1px 1px 3px;
}

element.alternate.normal selected,
element.alternate selected {
    border-color:     @accent;
    border-width:     1px 1px 1px 3px;
}

/* ── Icon (large glyph sits in the "icon" slot) ── */
element-icon {
    size:             0;        /* we embed icon in text; disable the image slot */
    background-color: transparent;
}

/* ── Label (icon glyph + name stacked) ── */
element-text {
    background-color: transparent;
    text-color:       @fg;
    horizontal-align: 0.5;
    vertical-align:   0.5;
    expand:           true;
}

/* ── Urgent tiles (optional — unused here but available) ── */
element.urgent.normal {
    border-color:     #e05c6a;
}

/* ── Message / no-results text ── */
message {
    background-color: transparent;
    padding:          8px 14px;
}
textbox {
    background-color: transparent;
    text-color:       @fg-dim;
    font:             "DepartureMono Nerd Font 10";
}
RASI

# ─── BUILD ENTRY LIST ──────────────────────────────────────────────────────────

LABELS=()
COMMANDS=()

for entry in "${APPS[@]}"; do
    label="${entry%%|*}"
    cmd="${entry##*|}"
    LABELS+=("$label")
    COMMANDS+=("$cmd")
done

# ─── LAUNCH ROFI ───────────────────────────────────────────────────────────────

# -format s    → return the selected display string
# -no-custom   → reject free-form input as a selection (but see NOTE below)
# If you remove -no-custom, any typed text that matches nothing becomes the
# SELECTION value and is sent to DuckDuckGo automatically.

SELECTION=$(printf '%s\n' "${LABELS[@]}" | rofi \
    -dmenu \
    -i \
    -p "󰍉" \
    -theme /home/user/.config/rofi/power.rasi \
    -format "s" \
    2>/dev/null)

EXIT_CODE=$?
rm -f "$TMPTHEME"

[[ $EXIT_CODE -eq 1 ]] && exit 0   # user pressed Esc

# ─── DISPATCH ──────────────────────────────────────────────────────────────────

if [[ -n "$SELECTION" ]]; then
    # Try to match against known apps first
    for i in "${!LABELS[@]}"; do
        if [[ "${LABELS[$i]}" == "$SELECTION" ]]; then
            eval "${COMMANDS[$i]}" &
            disown
            exit 0
        fi
    done

    # No app matched → treat input as a web search query
    QUERY=$(python3 -c \
        "import urllib.parse, sys; print(urllib.parse.quote_plus(sys.argv[1]))" \
        "$SELECTION" 2>/dev/null \
        || printf '%s' "$SELECTION" | sed 's/ /+/g')

    $BROWSER "https://duckduckgo.com/?q=${QUERY}" &
    disown
fi
RASI

# ─── ENABLE WEB SEARCH FALLBACK ────────────────────────────────────────────────
# To make the inputbar a live search bar for DuckDuckGo even when apps match:
#
#   Remove  -no-custom  above and add  -kb-custom-1 Return
#
# Then check $EXIT_CODE == 10 for custom-1 and use $SELECTION as the query.
# This lets Enter always launch the app, while a second keybind (e.g. Ctrl+Return)
# always opens DuckDuckGo — regardless of what's highlighted.