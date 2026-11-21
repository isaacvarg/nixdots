import QtQuick
import qs.style

// A floating capsule holding a row of bar widgets. With `bare` set it drops
// its background, which is how islands fold into the merged blob.
Rectangle {
	id: root

	default property alias content: row.data
	property bool bare: false

	// Hide the whole capsule when every widget in it is hidden (e.g. empty tray).
	visible: row.implicitWidth > 0
	implicitWidth: row.implicitWidth + Theme.islandPadding * 2
	implicitHeight: Theme.islandHeight
	radius: height / 2
	color: bare ? "transparent" : Theme.islandBg

	Behavior on color { ColorAnimation { duration: Theme.animDuration } }

	Row {
		id: row
		anchors.centerIn: parent
		spacing: 2
	}
}
