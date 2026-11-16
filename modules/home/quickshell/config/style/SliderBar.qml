import QtQuick
import QtQuick.Layouts

Item {
	id: slider

	property real value: 0
	property bool dimmed: false
	property color fillColor: Theme.accent
	property real wheelStep: 0.05
	readonly property real clamped: Math.max(0, Math.min(1, value))
	readonly property bool engaged: hover.hovered || mouse.pressed

	signal moved(real value)

	Layout.fillWidth: true
	implicitWidth: 120
	implicitHeight: 16

	HoverHandler { id: hover }

	Rectangle {
		id: track
		anchors.verticalCenter: parent.verticalCenter
		width: parent.width
		height: 6
		radius: height / 2
		color: Theme.chipBg

		Rectangle {
			width: handle.x + handle.width / 2
			height: parent.height
			radius: parent.radius
			color: slider.dimmed ? Theme.fgMuted : slider.fillColor
			Behavior on color { ColorAnimation { duration: Theme.animDuration } }
		}
	}

	Rectangle {
		id: handle
		anchors.verticalCenter: parent.verticalCenter
		x: (slider.width - width) * slider.clamped
		width: 12
		height: 12
		radius: width / 2
		color: Theme.fg
		scale: slider.engaged ? 1 : 0.75
		Behavior on scale { NumberAnimation { duration: Theme.animDuration } }
	}

	MouseArea {
		id: mouse
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		preventStealing: true

		function emit(x) {
			const usable = slider.width - handle.width
			slider.moved(Math.max(0, Math.min(1, (x - handle.width / 2) / usable)))
		}

		onPressed: m => emit(m.x)
		onPositionChanged: m => { if (pressed) emit(m.x) }
		onWheel: w => {
			const step = w.angleDelta.y > 0 ? slider.wheelStep : -slider.wheelStep
			slider.moved(Math.max(0, Math.min(1, slider.clamped + step)))
		}
	}
}
