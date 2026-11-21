pragma Singleton

import Quickshell
import QtQuick

// User-facing knobs. Edit and save: quickshell reloads on its own.
Singleton {
	// How the side islands sit relative to the centre blob:
	//   "grouped": hugging the blob, gap of islandGap either side
	//   "spread":  pushed out to the screen edges, edgeMargin in
	//   "merged":  everything folded into one wide blob
	readonly property string barLayout: "grouped"

	readonly property int islandGap: 8
	readonly property int edgeMargin: 8

	readonly property real tintStrength: 0.12
}
