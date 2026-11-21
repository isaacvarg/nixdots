import QtQuick
import qs.style

Item {
	id: tile
	required property var modelData
	required property int index
	readonly property bool hovered: hover.hovered
	signal clicked()

	HoverHandler { id: hover }

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
