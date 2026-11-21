import QtQuick
import qs.style

GridView {
	id: grid
	property var results: []
	property bool fixedHeight: false
	signal activated(var entry)

	readonly property int columns: Theme.launcherGridColumns
	readonly property int rows: fixedHeight
		? Theme.launcherGridRows
		: Math.min(Math.ceil(count / columns), Theme.launcherGridRows)
	implicitHeight: rows * cellHeight

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
		onHoveredChanged: if (hovered) grid.currentIndex = index
		onClicked: grid.activated(modelData)
	}
}
