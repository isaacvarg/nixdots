import QtQuick
import qs.style

GridView {
	id: grid
	property var results: []
	property bool fixedHeight: false
	signal activated(var entry)
	property var lastPointer: null

	readonly property int columns: Theme.launcherGridColumns
	readonly property int rows: fixedHeight
		? Theme.launcherGridRows
		: Math.min(Math.ceil(count / columns), Theme.launcherGridRows)
	implicitHeight: rows * cellHeight

	function hover(index, pos) {
		const moved = lastPointer && (pos.x !== lastPointer.x || pos.y !== lastPointer.y)
		lastPointer = pos
		if (moved) currentIndex = index
	}
	function step(n) { currentIndex = Math.max(0, Math.min(count - 1, currentIndex + n)) }
	function move(dx, dy) {
		step(dx + dy * columns)
		return true
	}

	cellWidth: width / columns
	cellHeight: Theme.launcherTileHeight
	model: results
	clip: true
	highlightMoveDuration: Theme.animDuration
	boundsBehavior: Flickable.StopAtBounds

	highlight: Rectangle {
		radius: Theme.radius
		color: Theme.chipBg
	}

	delegate: AppTile {
		width: grid.cellWidth
		height: grid.cellHeight
		onPointerMoved: pos => grid.hover(index, pos)
		onClicked: grid.activated(modelData)
	}
}
