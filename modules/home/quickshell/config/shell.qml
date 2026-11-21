import Quickshell
import QtQuick
import qs.bar
import qs.launcher

Scope {
	Variants {
		model: Quickshell.screens
		delegate: Component {
			Bar {}
		}
	}

	Launcher {}
}
