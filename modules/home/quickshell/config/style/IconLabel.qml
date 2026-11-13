import QtQuick

Row {
	id: root
	property string icon: ""
	property string text: ""
	property color color: Theme.fg

	spacing: Theme.spacingSmall

	BarText {
		anchors.verticalCenter: parent.verticalCenter
		visible: root.icon !== ""
		text: root.icon
		color: root.color
		font.pixelSize: Theme.iconSize
	}

	BarText {
		anchors.verticalCenter: parent.verticalCenter
		visible: root.text !== ""
		text: root.text
		color: root.color
	}
}
