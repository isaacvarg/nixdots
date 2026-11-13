import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import qs.style

PopupCard {
	id: popup
	property BluetoothAdapter adapter
	readonly property bool powered: adapter?.enabled ?? false
	readonly property bool scanning: adapter?.discovering ?? false

	onVisibleChanged: if (!visible && scanning) adapter.discovering = false

	// Header
	RowLayout {
		Layout.fillWidth: true
		spacing: Theme.spacingSmall

		BarText { text: "Bluetooth"; font.bold: true; Layout.fillWidth: true }

		Chip {
			visible: popup.powered
			active: popup.scanning
			onClicked: popup.adapter.discovering = !popup.scanning
			IconLabel {
				icon: "󰑓"
				text: popup.scanning ? "scanning" : "scan"
				color: popup.scanning ? Theme.fgOnAccent : Theme.fg
			}
		}

		Chip {
			active: popup.powered
			activeColor: Theme.good
			onClicked: popup.adapter.enabled = !popup.powered
			IconLabel {
				icon: popup.powered ? "󰂯" : "󰂲"
				text: popup.powered ? "on" : "off"
				color: popup.powered ? Theme.fgOnAccent : Theme.fgMuted
			}
		}
	}

	Divider {}

	// Devices
	Repeater {
		model: Bluetooth.devices

		delegate: ListItem {
			id: row
			required property BluetoothDevice modelData
			visible: popup.powered && (modelData.paired || popup.scanning)

			onClicked: {
				if (!modelData.paired) modelData.pair()
				else if (modelData.connected) modelData.disconnect()
				else modelData.connect()
			}

			BarText {
				Layout.fillWidth: true
				text: row.modelData.name || row.modelData.address
				color: row.modelData.connected ? Theme.info : Theme.fg
			}

			BarText {
				visible: row.modelData.batteryAvailable
				text: Math.round(row.modelData.battery * 100) + "%"
				muted: true
				small: true
			}

			BarText {
				muted: true
				text: row.modelData.state === BluetoothDeviceState.Connecting ? "…"
					: row.modelData.connected ? "󰂱"
					: !row.modelData.paired ? "pair"
					: ""
			}
		}
	}

	BarText {
		visible: !popup.powered
		text: "Adapter is off"
		muted: true
	}
}
