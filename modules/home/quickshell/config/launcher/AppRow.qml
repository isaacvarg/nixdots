import QtQuick
import QtQuick.Layouts
import qs.style

Item {
	id: row
	required property var modelData
	required property int index
	signal clicked()
	signal pointerMoved(point pos)

	implicitHeight: Theme.launcherRowHeight

	HoverHandler {
		onPointChanged: if (hovered) row.pointerMoved(point.scenePosition)
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		onClicked: row.clicked()
	}

	RowLayout {
		anchors.fill: parent
		anchors.leftMargin: Theme.spacingSmall
		anchors.rightMargin: Theme.spacingSmall
		spacing: Theme.spacing

		AppIcon { entry: row.modelData }

		BarText {
			text: row.modelData.name
			Layout.maximumWidth: row.width * 0.5
		}

		BarText {
			Layout.fillWidth: true
			text: row.modelData.genericName || row.modelData.comment
			muted: true
			small: true
		}
	}
}
