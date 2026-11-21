import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.style

Scope {
	id: root
	property bool open: false

	IpcHandler {
		target: "launcher"
		function toggle(): void { root.open = !root.open }
		function open(): void { root.open = true }
		function close(): void { root.open = false }
	}

	LazyLoader {
		active: root.open

		PanelWindow {
			id: win
			screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null
			anchors { top: true; bottom: true; left: true; right: true }
			color: "transparent"
			exclusionMode: ExclusionMode.Ignore
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
			WlrLayershell.namespace: "quickshell-launcher"

			readonly property var results: Apps.search(input.text)

			function launch(entry) {
				if (!entry) return
				Apps.launch(entry)
				root.open = false
			}

			MouseArea {
				anchors.fill: parent
				onClicked: root.open = false
			}

			Rectangle {
				id: card
				width: Theme.launcherWidth
				height: column.implicitHeight + Theme.padding * 2
				x: (parent.width - width) / 2
				y: parent.height * 0.22
				color: Theme.popupBg
				border.color: Theme.border
				border.width: 1
				radius: Theme.radiusLarge

				MouseArea { anchors.fill: parent }

				ColumnLayout {
					id: column
					anchors.fill: parent
					anchors.margins: Theme.padding
					spacing: Theme.spacingSmall

					RowLayout {
						Layout.fillWidth: true
						Layout.preferredHeight: Theme.launcherRowHeight
						Layout.leftMargin: Theme.spacingSmall
						spacing: Theme.spacing

						BarText {
							text: "󰍉"
							color: Theme.accent
							font.pixelSize: Theme.iconSize + 3
						}

						TextInput {
							id: input
							Layout.fillWidth: true
							focus: true
							color: Theme.fg
							selectionColor: Theme.accent
							selectedTextColor: Theme.fgOnAccent
							font.family: Theme.fontFamily
							font.pixelSize: Theme.fontSize + 3
							clip: true

							onTextChanged: list.currentIndex = 0

							BarText {
								visible: input.text === ""
								text: "Search apps"
								muted: true
								font.pixelSize: input.font.pixelSize
							}

							Keys.onPressed: event => {
								const ctrl = event.modifiers & Qt.ControlModifier
								if (event.key === Qt.Key_Escape) root.open = false
								else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
									win.launch(win.results[list.currentIndex])
								else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab
										|| (ctrl && (event.key === Qt.Key_J || event.key === Qt.Key_N)))
									list.incrementCurrentIndex()
								else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab
										|| (ctrl && (event.key === Qt.Key_K || event.key === Qt.Key_P)))
									list.decrementCurrentIndex()
								else return
								event.accepted = true
							}
						}
					}

					Divider { visible: win.results.length > 0 }

					ListView {
						id: list
						Layout.fillWidth: true
						Layout.preferredHeight: Math.min(count, Theme.launcherRows) * Theme.launcherRowHeight
						visible: count > 0
						clip: true
						model: win.results
						highlightMoveDuration: Theme.animDuration
						boundsBehavior: Flickable.StopAtBounds

						highlight: Rectangle {
							radius: Theme.radius
							color: Theme.chipBg
						}

						delegate: AppRow {
							width: list.width
							onHoveredChanged: if (hovered) list.currentIndex = index
							onClicked: win.launch(modelData)
						}
					}

					BarText {
						visible: win.results.length === 0 && input.text !== ""
						Layout.fillWidth: true
						Layout.preferredHeight: Theme.launcherRowHeight
						horizontalAlignment: Text.AlignHCenter
						text: "No matches"
						muted: true
					}
				}
			}
		}
	}
}
