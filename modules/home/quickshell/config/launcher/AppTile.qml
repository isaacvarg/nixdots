import QtQuick
import qs.style

Item {
	id: tile
	required property var modelData
	required property int index
	signal clicked()
	signal pointerMoved(point pos)

	HoverHandler {
		onPointChanged: if (hovered) tile.pointerMoved(point.scenePosition)
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		onClicked: tile.clicked()
	}

	Column {
		anchors.centerIn: parent
		width: parent.width - Theme.spacingSmall * 2
		spacing: Theme.spacingSmall

		AppIcon {
			anchors.horizontalCenter: parent.horizontalCenter
			entry: tile.modelData
			size: Theme.launcherTileIconSize
		}

		BarText {
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			text: tile.modelData.name
			small: true
		}
	}
}
