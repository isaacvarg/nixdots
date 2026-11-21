import Quickshell
import QtQuick
import qs.style

Item {
	id: root
	required property var entry
	property int size: Theme.launcherIconSize
	readonly property string source: Quickshell.iconPath(entry.icon, true)

	implicitWidth: size
	implicitHeight: size

	Image {
		anchors.fill: parent
		visible: root.source !== ""
		source: root.source
		sourceSize.width: root.size
		sourceSize.height: root.size
		asynchronous: true
	}

	Rectangle {
		anchors.fill: parent
		visible: root.source === ""
		radius: Theme.radius
		color: Theme.chipBgHover

		BarText {
			anchors.centerIn: parent
			text: root.entry.name.charAt(0).toUpperCase()
			color: Theme.accent
			font.bold: true
			font.pixelSize: root.size * 0.5
		}
	}
}
