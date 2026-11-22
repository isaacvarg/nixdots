pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
	id: root
	property bool on: false

	function toggle(): void { on = !on }

	IpcHandler {
		target: "caffeine"
		function toggle(): void { root.toggle() }
	}
}
