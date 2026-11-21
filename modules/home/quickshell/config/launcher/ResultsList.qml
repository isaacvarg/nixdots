import QtQuick
import qs.style

ListView {
	id: list
	property var results: []
	property bool fixedHeight: false
	signal activated(var entry)

	readonly property int rows: fixedHeight ? Theme.launcherRows : Math.min(count, Theme.launcherRows)
	implicitHeight: rows * Theme.launcherRowHeight

	function step(n) { currentIndex = Math.max(0, Math.min(count - 1, currentIndex + n)) }
	function move(dx, dy) {
		if (dy === 0) return false
		step(dy)
		return true
	}

	model: results
	clip: true
	highlightMoveDuration: Theme.animDuration
	boundsBehavior: Flickable.StopAtBounds

	highlight: Rectangle {
		width: list.width
		radius: Theme.radius
		color: Theme.chipBg
	}

	delegate: AppRow {
		width: list.width
		onHoveredChanged: if (hovered) list.currentIndex = index
		onClicked: list.activated(modelData)
	}
}
