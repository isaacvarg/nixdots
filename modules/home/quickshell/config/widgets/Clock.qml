import Quickshell
import QtQuick
import qs.style

Chip {
	flat: true

	SystemClock { id: clock; precision: SystemClock.Minutes }

	BarText {
		anchors.verticalCenter: parent.verticalCenter
		text: Qt.formatDateTime(clock.date, "hh:mm ap")
	}
}
