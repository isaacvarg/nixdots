import QtQuick
import qs.style

Chip {
	id: root
	flat: true
	visible: Todoist.ready

	active: popup.visible
	onClicked: popup.visible = !popup.visible

	IconLabel {
		icon: "󰄲"
		text: Todoist.tasks.length > 0 ? Todoist.tasks.length : ""
		color: root.active ? Theme.fgOnAccent
			: Todoist.error !== "" ? Theme.fgMuted
			: Theme.fg
	}

	TodoistPopup {
		id: popup
		anchorItem: root
	}
}
