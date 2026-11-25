import QtQuick
import qs.style

ListView {
	id: list
	property var results: []
	property bool fixedHeight: false
	signal activated(var entry)
	property var lastPointer: null

	readonly property int rows: fixedHeight ? Theme.launcherRows : Math.min(count, Theme.launcherRows)
	implicitHeight: rows * Theme.launcherRowHeight

	function hover(index, pos) {
		const moved = lastPointer && (pos.x !== lastPointer.x || pos.y !== lastPointer.y)
		lastPointer = pos
		if (moved) currentIndex = index
	}
	function step(n) { currentIndex = Math.max(0, Math.min(count - 1, currentIndex + n)) }
	function move(dx, dy) {
		if (dy === 0) return false
		step(dy)
		return true
	}

	model: results
	clip: true
	highlightMoveDuration: Theme.animDuration
	highlightResizeDuration: 0
	boundsBehavior: Flickable.StopAtBounds

	highlight: Rectangle {
		radius: Theme.radius
		color: Theme.chipBg
	}

	delegate: AppRow {
		width: list.width
		onPointerMoved: pos => list.hover(index, pos)
		onClicked: list.activated(modelData)
	}
}
