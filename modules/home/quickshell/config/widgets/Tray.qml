import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import qs.style

Chip {
	id: root
	flat: true
	visible: SystemTray.items.values.length > 0
	interactive: false

	Repeater {
		model: SystemTray.items

		delegate: IconImage {
			id: icon
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
						if (icon.modelData.onlyMenu && icon.modelData.hasMenu) menu.open(icon.modelData, icon)
						else icon.modelData.activate()
					} else if (icon.modelData.hasMenu) {
						menu.open(icon.modelData, icon)
					}
				}
			}
		}
	}

	TrayMenuPopup {
		id: menu
		anchorItem: root
	}
}
