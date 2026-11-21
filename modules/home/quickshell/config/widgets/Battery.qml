import Quickshell.Services.UPower
import QtQuick
import qs.style

/* i have yet to configure laptop host/system
 * for nixos so this is a placeholder
 * we would have to enable/install UPower
 * on nixos
*/

Chip {
	id: root
	flat: true
	readonly property var bat: UPower.displayDevice
	readonly property real pct: bat.percentage
	readonly property bool charging: bat.state === UPowerDeviceState.Charging

	visible: bat.isLaptopBattery
	interactive: false

	IconLabel {
		icon: root.charging ? "󰂄"
			: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"][Math.round(root.pct * 10)]
		text: Math.round(root.pct * 100) + "%"
		color: root.charging ? Theme.good
			: root.pct < 0.15 ? Theme.critical
			: root.pct < 0.30 ? Theme.warn
			: Theme.fg
	}
}
