import QtQuick

Rectangle {
	id: chip

	default property alias content: row.data
	property bool active: false
	property bool interactive: true
	// No resting background; used for chips that sit on an island.
	property bool flat: false
	property int padding: 8
	property color activeColor: Theme.accent
	property alias acceptedButtons: mouse.acceptedButtons
	readonly property bool hovered: hover.hovered

	signal clicked(var mouse)
	signal scrolled(var wheel)

	implicitWidth: row.implicitWidth + padding * 2
	implicitHeight: Theme.chipHeight
	radius: flat ? height / 2 : Theme.radius
	color: active ? activeColor
		: (interactive && hovered) ? Theme.chipBgHover
		: flat ? "transparent"
		: Theme.chipBg

	Behavior on color { ColorAnimation { duration: Theme.animDuration } }
	Behavior on implicitWidth { NumberAnimation { duration: Theme.animDuration } }

	HoverHandler { id: hover }

	Row {
		id: row
		anchors.centerIn: parent
		spacing: Theme.spacingSmall
	}

	MouseArea {
		id: mouse
		anchors.fill: parent
		enabled: chip.interactive
		cursorShape: Qt.PointingHandCursor
		onClicked: m => chip.clicked(m)
		onWheel: w => chip.scrolled(w)
	}
}
