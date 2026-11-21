import Quickshell
import QtQuick
import qs.style

Chip {
	interactive: false
	flat: true

	SystemClock { id: clock; precision: SystemClock.Minutes }

	IconLabel {
		icon: "󰥔"
		text: Qt.formatDateTime(clock.date, "ddd MMM d   hh:mm")
	}
}
