import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import qs.style

Scope {
	LazyLoader {
		active: Power.open

		PanelWindow {
			id: win
			screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null
			anchors { top: true; bottom: true; left: true; right: true }
			color: Theme.powerScrim
			exclusionMode: ExclusionMode.Ignore
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
			WlrLayershell.namespace: "quickshell-powermenu"

			property int current: 0
			readonly property int count: Power.actions.length

			function step(d) { current = (current + d + count) % count }

			MouseArea {
				anchors.fill: parent
				onClicked: Power.open = false
			}

			Rectangle {
				anchors.centerIn: parent
				width: tiles.implicitWidth + Theme.padding * 2
				height: tiles.implicitHeight + Theme.padding * 2
				color: Theme.popupBg
				border.color: Theme.border
				border.width: 1
				radius: Theme.radiusLarge

				MouseArea { anchors.fill: parent }

				Row {
					id: tiles
					anchors.centerIn: parent
					spacing: Theme.spacingSmall
					focus: true

					Keys.onPressed: event => {
						const key = event.key
						let handled = true

						if (key === Qt.Key_Escape) Power.open = false
						else if (key === Qt.Key_Return || key === Qt.Key_Enter || key === Qt.Key_Space)
							Power.run(Power.actions[win.current])
						else if (key === Qt.Key_Right || key === Qt.Key_L || key === Qt.Key_Tab) win.step(1)
						else if (key === Qt.Key_Left || key === Qt.Key_H || key === Qt.Key_Backtab) win.step(-1)
						else if (key >= Qt.Key_1 && key < Qt.Key_1 + win.count)
							Power.run(Power.actions[key - Qt.Key_1])
						else handled = false

						event.accepted = handled
					}

					Repeater {
						model: Power.actions

						Rectangle {
							id: tile
							required property var modelData
							required property int index
							readonly property bool selected: win.current === index

							width: Theme.powerTileSize
							height: Theme.powerTileSize
							radius: Theme.radiusLarge
							color: selected ? Theme.accent : Theme.chipBg

							Behavior on color { ColorAnimation { duration: Theme.animDuration } }

							HoverHandler {
								onHoveredChanged: if (hovered) win.current = tile.index
							}

							MouseArea {
								anchors.fill: parent
								cursorShape: Qt.PointingHandCursor
								onClicked: Power.run(tile.modelData)
							}

							BarText {
								anchors.top: parent.top
								anchors.right: parent.right
								anchors.margins: Theme.spacingSmall
								text: tile.index + 1
								small: true
								color: tile.selected ? Theme.fgOnAccent : Theme.fgMuted
							}

							Column {
								anchors.centerIn: parent
								spacing: Theme.spacingSmall

								BarText {
									anchors.horizontalCenter: parent.horizontalCenter
									text: tile.modelData.icon
									color: tile.selected ? Theme.fgOnAccent : Theme.fg
									font.pixelSize: Theme.powerIconSize
								}

								BarText {
									anchors.horizontalCenter: parent.horizontalCenter
									text: tile.modelData.name
									color: tile.selected ? Theme.fgOnAccent : Theme.fg
								}
							}
						}
					}
				}
			}
		}
	}
}
