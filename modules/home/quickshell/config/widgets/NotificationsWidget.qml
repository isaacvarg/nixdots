import QtQuick
import qs.notifications
import qs.style

Chip {
	id: root
	flat: true

	active: popup.visible
	acceptedButtons: Qt.LeftButton | Qt.RightButton
	onClicked: mouse => {
		if (mouse.button === Qt.RightButton) Notifs.dnd = !Notifs.dnd
		else popup.visible = !popup.visible
	}

	IconLabel {
		icon: Notifs.dnd ? "󰂛" : Notifs.count > 0 ? "󰂚" : "󰂜"
		text: Notifs.count > 0 ? Notifs.count : ""
		color: root.active ? Theme.fgOnAccent
			: Notifs.dnd ? Theme.fgMuted
			: Theme.fg
	}

	NotificationsPopup {
		id: popup
		anchorItem: root
	}
}
