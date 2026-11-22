pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
	id: root
	property bool open: false

	readonly property var actions: [
		{ name: "Lock",     icon: "󰌾", cmd: ["lock-screen"] },
		{ name: "Reboot",   icon: "󰜉", cmd: ["systemctl", "reboot"] },
		{ name: "Poweroff", icon: "󰐥", cmd: ["systemctl", "poweroff"] },
		{ name: "BIOS",     icon: "󰍛", cmd: ["systemctl", "reboot", "--firmware-setup"] }
	]

	function toggle(): void { open = !open }

	function run(action): void {
		if (!action) return
		open = false
		Quickshell.execDetached(action.cmd)
	}

	IpcHandler {
		target: "powermenu"
		function toggle(): void { root.toggle() }
		function open(): void { root.open = true }
		function close(): void { root.open = false }
	}
}
