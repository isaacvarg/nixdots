pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import qs.settings

// Owns org.freedesktop.Notifications. All notifs tracked → history; popups = subset shown as toasts.
Singleton {
	id: root

	property bool dnd: false
	property list<Notification> popups: []
	readonly property var history: server.trackedNotifications.values.slice().reverse()
	readonly property int count: server.trackedNotifications.values.length

	function hidePopup(n) {
		popups = popups.filter(p => p !== n)
	}

	function clearAll() {
		popups = []
		for (const n of server.trackedNotifications.values.slice()) n.dismiss()
	}

	NotificationServer {
		id: server
		keepOnReload: true
		bodySupported: true
		bodyMarkupSupported: true
		actionsSupported: true
		imageSupported: true
		persistenceSupported: true

		onNotification: n => {
			n.tracked = true
			n.closed.connect(() => root.hidePopup(n))
			if (root.dnd && n.urgency !== NotificationUrgency.Critical) return
			root.popups = [n, ...root.popups].slice(0, Settings.notifMaxPopups)
		}
	}

	IpcHandler {
		target: "notifications"
		function toggleDnd(): void { root.dnd = !root.dnd }
		function clear(): void { root.clearAll() }
	}
}
