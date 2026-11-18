import Quickshell
import QtQuick
import qs.style
import qs.widgets

PanelWindow {
	id: root
	required property var modelData
	screen: modelData

	anchors { top: true; left: true; right: true }
	implicitHeight: Theme.barHeight
	color: Theme.barBg

	// Left
	Workspaces {
		screen: root.screen
		anchors.left: parent.left
		anchors.leftMargin: Theme.padding
		anchors.verticalCenter: parent.verticalCenter
	}

	// Center
	Clock {
		anchors.centerIn: parent
	}

	// Right
	Row {
		anchors.right: parent.right
		anchors.rightMargin: Theme.padding
		anchors.verticalCenter: parent.verticalCenter
		spacing: Theme.spacingSmall

		Tray            { anchors.verticalCenter: parent.verticalCenter }
		BluetoothWidget { anchors.verticalCenter: parent.verticalCenter }
		Volume          { anchors.verticalCenter: parent.verticalCenter }
		Battery         { anchors.verticalCenter: parent.verticalCenter }
	}
}
