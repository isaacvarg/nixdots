import Quickshell
import QtQuick
import qs.bar
import qs.launcher
import qs.notifications

Scope {
	Variants {
		model: Quickshell.screens
		delegate: Component {
			Bar {}
		}
	}

	Launcher {}
	Toasts {}
}
