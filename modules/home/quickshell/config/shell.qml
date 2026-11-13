import Quickshell
import QtQuick
import qs.bar

Scope {
	Variants {
		model: Quickshell.screens
		delegate: Component {
			Bar {}
		}
	}
}
