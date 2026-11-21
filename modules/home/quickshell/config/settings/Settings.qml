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
}
