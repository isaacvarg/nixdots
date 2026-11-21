import Quickshell.Widgets
import QtQuick
import qs.style

ClippingRectangle {
	id: root
	property string source: ""
	readonly property bool shown: source !== "" && img.status !== Image.Error

	visible: shown
	radius: Theme.radius
	color: Theme.chipBg

	Image {
		id: img
		anchors.fill: parent
		source: root.source
		fillMode: Image.PreserveAspectCrop
		sourceSize.width: 1024
		asynchronous: true
		cache: false
	}
}
