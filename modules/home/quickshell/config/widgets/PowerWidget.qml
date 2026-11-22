import QtQuick
import qs.powermenu
import qs.style

Chip {
	id: root
	flat: true
	active: Power.open
	onClicked: Power.toggle()

	IconLabel {
		icon: "󰐥"
		color: root.active ? Theme.fgOnAccent : Theme.fg
	}
}
