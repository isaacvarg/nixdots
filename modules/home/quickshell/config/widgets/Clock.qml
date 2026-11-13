import Quickshell
import QtQuick
import qs.style

Chip {
	interactive: false

	SystemClock { id: clock; precision: SystemClock.Minutes }

	IconLabel {
		icon: "󰥔"
		text: Qt.formatDateTime(clock.date, "ddd MMM d   hh:mm")
	}
}
