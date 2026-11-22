pragma Singleton

import Quickshell
import QtQuick

Singleton {
	// How the side islands sit relative to the centre blob:
	//   "grouped": hugging the blob, gap of islandGap either side
	//   "spread":  pushed out to the screen edges, edgeMargin in
	//   "merged":  everything folded into one wide blob
	readonly property string barLayout: "spread"

	readonly property int islandGap: 8
	readonly property int edgeMargin: 8

	readonly property real tintStrength: 0.20

	// Launcher look:
	//   launcherLayout: "list" | "grid" | "split" (image panel on left)
	//   launcherImage:  "wallpaper" follows skwd, "file" shows launcherImagePath,
	//                   "folder" picks random image from launcherImagePath each open,
	//                   "none" hides it
	readonly property string launcherLayout: "list"
	readonly property string launcherImage: "wallpaper"
	readonly property string launcherImagePath: ""

	// Toasts: ms on screen when app gives no timeout; critical ones stay
	readonly property int notifTimeout: 5000
	readonly property int notifMaxPopups: 5

	// Lock screen: blur/dim 0–1, *Typing used while password field shows;
	// idle timeout ms clears field, back to clock
	readonly property real lockBlur: 0.4
	readonly property real lockBlurTyping: 1.0
	readonly property real lockDim: 0.1
	readonly property real lockDimTyping: 0.35
	readonly property int lockIdleTimeout: 10000
}
