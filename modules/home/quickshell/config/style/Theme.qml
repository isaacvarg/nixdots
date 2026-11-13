pragma Singleton

import Quickshell
import QtQuick

Singleton {
	// ── Catppuccin Macchiato palette ─────────────────────────
	readonly property color rosewater: "#f4dbd6"
	readonly property color flamingo:  "#f0c6c6"
	readonly property color pink:      "#f5bde6"
	readonly property color mauve:     "#c6a0f6"
	readonly property color red:       "#ed8796"
	readonly property color maroon:    "#ee99a0"
	readonly property color peach:     "#f5a97f"
	readonly property color yellow:    "#eed49f"
	readonly property color green:     "#a6da95"
	readonly property color teal:      "#8bd5ca"
	readonly property color sky:       "#91d7e3"
	readonly property color sapphire:  "#7dc4e4"
	readonly property color blue:      "#8aadf4"
	readonly property color lavender:  "#b7bdf8"
	readonly property color text:      "#cad3f5"
	readonly property color subtext1:  "#b8c0e0"
	readonly property color subtext0:  "#a5adcb"
	readonly property color overlay2:  "#939ab7"
	readonly property color overlay1:  "#8087a2"
	readonly property color overlay0:  "#6e738d"
	readonly property color surface2:  "#5b6078"
	readonly property color surface1:  "#494d64"
	readonly property color surface0:  "#363a4f"
	readonly property color base:      "#24273a"
	readonly property color mantle:    "#1e2030"
	readonly property color crust:     "#181926"

	// ── Semantic roles (widgets use these, never raw palette names) ─
	readonly property color barBg:       mantle
	readonly property color fg:          text
	readonly property color fgMuted:     overlay1
	readonly property color fgOnAccent:  crust
	readonly property color accent:      mauve
	readonly property color chipBg:      surface0
	readonly property color chipBgHover: surface1
	readonly property color popupBg:     base
	readonly property color border:      surface1
	readonly property color good:        green
	readonly property color warn:        peach
	readonly property color critical:    red
	readonly property color info:        blue

	// ── Typography ──────────────────────────────────────────
	readonly property string fontFamily: "JetBrainsMono Nerd Font"
	readonly property int fontSize: 13
	readonly property int fontSizeSmall: 11
	readonly property int iconSize: 15

	// ── Shape & spacing ─────────────────────────────────────
	readonly property int barHeight: 32
	readonly property int chipHeight: 22
	readonly property int listItemHeight: 30
	readonly property int radius: 6
	readonly property int radiusLarge: 12
	readonly property int padding: 10
	readonly property int spacing: 12
	readonly property int spacingSmall: 6
	readonly property int popupGap: 6
	readonly property int popupWidth: 280

	// ── Motion ──────────────────────────────────────────────
	readonly property int animDuration: 150
}
