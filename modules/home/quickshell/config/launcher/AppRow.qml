import QtQuick
import QtQuick.Layouts
import qs.style

Item {
	id: row
	required property var modelData
	required property int index
	readonly property bool hovered: hover.hovered
	signal clicked()

	implicitHeight: Theme.launcherRowHeight

	HoverHandler { id: hover }

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
