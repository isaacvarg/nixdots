import Quickshell
import QtQuick
import QtQuick.Layouts

PopupWindow {
	id: card

	required property Item anchorItem
	default property alias content: column.data
	property int cardWidth: Theme.popupWidth

	grabFocus: true
	anchor.item: anchorItem
	anchor.edges: Edges.Bottom
	anchor.gravity: Edges.Bottom
	anchor.margins.top: Theme.popupGap

	implicitWidth: cardWidth
	implicitHeight: column.implicitHeight + Theme.padding * 2
	color: "transparent"

	Rectangle {
		anchors.fill: parent
		color: Theme.popupBg
		border.color: Theme.border
		border.width: 1
		radius: Theme.radiusLarge

		ColumnLayout {
			id: column
			anchors.fill: parent
			anchors.margins: Theme.padding
			spacing: Theme.spacingSmall
		}
	}
}
