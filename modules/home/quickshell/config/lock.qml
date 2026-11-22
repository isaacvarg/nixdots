import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.lock

ShellRoot {
	id: root
	readonly property bool preview: Quickshell.env("LOCK_PREVIEW") === "1"

	settings.watchFiles: preview

	LockContext {
		id: ctx
		preview: root.preview
		onUnlocked: {
			lock.locked = false
			quitTimer.start()
		}
	}

	Timer {
		id: quitTimer
		interval: 200
		onTriggered: Qt.quit()
	}

	WlSessionLock {
		id: lock
		locked: !root.preview

		WlSessionLockSurface {
			color: "black"

			LockSurface {
				anchors.fill: parent
				context: ctx
			}
		}
	}

	Variants {
		model: root.preview ? Quickshell.screens : []

		PanelWindow {
			required property var modelData
			screen: modelData

			anchors { top: true; bottom: true; left: true; right: true }
			exclusionMode: ExclusionMode.Ignore
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
			color: "black"

			LockSurface {
				anchors.fill: parent
				context: ctx
			}
		}
	}
}
