import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.style

Item {
	id: row
	required property var modelData
	required property int index
	readonly property bool hovered: hover.hovered
	readonly property string iconSource: Quickshell.iconPath(modelData.icon, true)
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

		Item {
			implicitWidth: Theme.launcherIconSize
			implicitHeight: Theme.launcherIconSize

			Image {
				anchors.fill: parent
				visible: row.iconSource !== ""
				source: row.iconSource
				sourceSize.width: Theme.launcherIconSize
				sourceSize.height: Theme.launcherIconSize
				asynchronous: true
			}

			Rectangle {
				anchors.fill: parent
				visible: row.iconSource === ""
				radius: Theme.radius
				color: Theme.chipBgHover

				BarText {
					anchors.centerIn: parent
					text: row.modelData.name.charAt(0).toUpperCase()
					color: Theme.accent
					font.bold: true
				}
			}
		}

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
