import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import qs.style

Chip {
	visible: SystemTray.items.values.length > 0
	interactive: false

	Repeater {
		model: SystemTray.items

		delegate: IconImage {
			required property SystemTrayItem modelData
			anchors.verticalCenter: parent.verticalCenter
			source: modelData.icon
			implicitSize: Theme.iconSize

			MouseArea {
				anchors.fill: parent
				acceptedButtons: Qt.LeftButton | Qt.RightButton
				cursorShape: Qt.PointingHandCursor
				onClicked: mouse => {
					if (mouse.button === Qt.LeftButton) {
						modelData.activate()
					} else if (modelData.hasMenu) {
						const p = mapToItem(null, mouse.x, mouse.y)
						modelData.display(QsWindow.window, p.x, p.y)
					}
				}
			}
		}
	}
}
