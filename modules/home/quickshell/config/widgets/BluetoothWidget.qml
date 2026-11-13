import Quickshell
import Quickshell.Bluetooth
import QtQuick
import qs.style

Chip {
	id: root
	readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
	readonly property bool powered: adapter?.enabled ?? false
	readonly property var connected: Bluetooth.devices.values.filter(d => d.connected)

	active: popup.visible
	acceptedButtons: Qt.LeftButton | Qt.RightButton
	onClicked: mouse => {
		if (mouse.button === Qt.RightButton) {
			if (adapter) adapter.enabled = !adapter.enabled
		} else {
			popup.visible = !popup.visible
		}
	}

	IconLabel {
		readonly property color stateColor: !root.powered ? Theme.fgMuted
			: root.connected.length > 0 ? Theme.info
			: Theme.fg

		icon: !root.powered ? "󰂲" : root.connected.length > 0 ? "󰂱" : "󰂯"
		text: !root.adapter ? ""
			: !root.powered ? "off"
			: root.connected.length === 1 ? root.connected[0].name
			: root.connected.length > 1 ? root.connected.length + " devices"
			: ""
		color: root.active ? Theme.fgOnAccent : stateColor
	}

	BluetoothPopup {
		id: popup
		anchorItem: root
		adapter: root.adapter
	}
}
