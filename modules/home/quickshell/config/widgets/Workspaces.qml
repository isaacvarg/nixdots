import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.style

Row {
	id: root

	// The screen this bar is on; only workspaces on its monitor are shown.
	required property ShellScreen screen

	spacing: Theme.spacingSmall

	Repeater {
		model: Hyprland.workspaces

		delegate: Chip {
			required property HyprlandWorkspace modelData

			visible: modelData.id > 0 && modelData.monitor?.name === root.screen?.name
			active: modelData.focused
			padding: modelData.focused ? 12 : 8
			onClicked: modelData.activate()

			BarText {
				text: modelData.id
				color: modelData.focused ? Theme.fgOnAccent : Theme.fg
			}
		}
	}
}
