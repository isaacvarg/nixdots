import QtQuick
import QtQuick.Layouts
import qs.notifications
import qs.style

PopupCard {
	id: popup
	cardWidth: Theme.notifWidth

	onVisibleChanged: if (visible) Notifs.popups = []

	RowLayout {
		Layout.fillWidth: true
		spacing: Theme.spacingSmall

		BarText { text: "Notifications"; font.bold: true; Layout.fillWidth: true }

		Chip {
			visible: Notifs.count > 0
			onClicked: Notifs.clearAll()
			IconLabel { icon: "󰎟"; text: "clear" }
		}

		Chip {
			active: Notifs.dnd
			onClicked: Notifs.dnd = !Notifs.dnd
			IconLabel {
				icon: Notifs.dnd ? "󰂛" : "󰂚"
				text: "dnd"
				color: Notifs.dnd ? Theme.fgOnAccent : Theme.fg
			}
		}
	}

	Divider {}

	Flickable {
		Layout.fillWidth: true
		Layout.preferredHeight: Math.min(list.implicitHeight, Theme.notifHistoryHeight)
		visible: Notifs.count > 0
		contentHeight: list.implicitHeight
		clip: true
		boundsBehavior: Flickable.StopAtBounds

		ColumnLayout {
			id: list
			width: parent.width
			spacing: 2

			Repeater {
				model: Notifs.history

				delegate: NotificationCard {
					required property var modelData
					notification: modelData
					Layout.fillWidth: true
				}
			}
		}
	}

	BarText {
		visible: Notifs.count === 0
		Layout.fillWidth: true
		Layout.preferredHeight: Theme.launcherRowHeight
		horizontalAlignment: Text.AlignHCenter
		text: "All caught up"
		muted: true
	}
}
