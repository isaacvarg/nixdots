import Quickshell
import QtQuick
import qs.bar
import qs.launcher
import qs.notifications
import qs.powermenu

Scope {
	Variants {
		model: Quickshell.screens
		delegate: Component {
			Bar {}
		}
	}

	Launcher {}
	Toasts {}
	PowerMenu {}
}
