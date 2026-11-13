import QtQuick
import QtQuick.Layouts

Rectangle {
	id: item

	default property alias content: row.data
	signal clicked(var mouse)

	Layout.fillWidth: true
	implicitHeight: Theme.listItemHeight
	radius: Theme.radius
	color: hover.hovered ? Theme.chipBg : "transparent"

	Behavior on color { ColorAnimation { duration: Theme.animDuration } }

	HoverHandler { id: hover }

	RowLayout {
		id: row
		anchors.fill: parent
		anchors.leftMargin: Theme.spacingSmall + 2
		anchors.rightMargin: Theme.spacingSmall + 2
		spacing: Theme.spacingSmall
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		onClicked: m => item.clicked(m)
	}
}
