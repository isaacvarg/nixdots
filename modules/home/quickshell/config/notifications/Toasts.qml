import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import qs.settings
import qs.style

PanelWindow {
	id: win

	visible: Notifs.popups.length > 0
	screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
	anchors { top: true; right: true }
	margins { top: Theme.popupGap; right: Settings.edgeMargin }
	implicitWidth: Theme.notifWidth
	implicitHeight: Math.max(1, column.implicitHeight)
	color: "transparent"
	exclusionMode: ExclusionMode.Normal
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.namespace: "quickshell-notifications"

	mask: Region { item: column }

	Column {
		id: column
		width: parent.width
		spacing: Theme.spacingSmall

		move: Transition {
			NumberAnimation { property: "y"; duration: Theme.animDuration * 2; easing.type: Easing.OutCubic }
		}

		Repeater {
			model: Notifs.popups

			delegate: NotificationCard {
				required property var modelData
				notification: modelData
				toast: true
				width: column.width
				clip: true

				opacity: 0
				x: Theme.notifWidth / 3
				Component.onCompleted: { opacity = 1; x = 0 }
				Behavior on opacity { NumberAnimation { duration: Theme.animDuration * 2 } }
				Behavior on x { NumberAnimation { duration: Theme.animDuration * 2; easing.type: Easing.OutCubic } }
			}
		}
	}
}
