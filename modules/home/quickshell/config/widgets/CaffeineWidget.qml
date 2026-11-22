import QtQuick
import qs.style

Chip {
	id: root
	flat: true
	active: Caffeine.on
	onClicked: Caffeine.toggle()

	IconLabel {
		icon: Caffeine.on ? "󰅶" : "󰛊"
		color: root.active ? Theme.fgOnAccent : Theme.fgMuted
	}
}
