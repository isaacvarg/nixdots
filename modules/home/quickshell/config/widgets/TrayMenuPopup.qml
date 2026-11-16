import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.style

PopupCard {
	id: popup
	cardWidth: 260

	property SystemTrayItem trayItem
	// Submenus the user has stepped into; the last one is shown.
	property var stack: []
	readonly property var current: stack.length > 0 ? stack[stack.length - 1] : trayItem?.menu ?? null

	function open(item, target) {
		if (visible && trayItem === item) {
			visible = false
			return
		}
		visible = false
		trayItem = item
		stack = []
		anchorItem = target
		popup.anchor.updateAnchor()
		visible = true
	}

	function cleanLabel(text) {
		// DBusMenu marks mnemonics with "_"; "__" is a literal underscore.
		return (text ?? "").replace(/__/g, "\u0000").replace(/_/g, "").replace(/\u0000/g, "_")
	}

	onVisibleChanged: if (!visible) stack = []

	QsMenuOpener {
		id: opener
		menu: popup.visible ? popup.current : null
	}

	BarText {
		Layout.fillWidth: true
		font.bold: true
		text: popup.trayItem
			? (popup.trayItem.tooltipTitle || popup.trayItem.title || popup.trayItem.id)
			: ""
	}

	Divider {}

	ListItem {
		visible: popup.stack.length > 0
		onClicked: popup.stack = popup.stack.slice(0, -1)

		BarText { text: "󰁍"; muted: true }
		BarText {
			Layout.fillWidth: true
			text: popup.stack.length > 0 ? popup.cleanLabel(popup.current.text) : ""
			muted: true
		}
	}

	Repeater {
		model: opener.children

		delegate: Loader {
			id: entry
			required property QsMenuEntry modelData
			Layout.fillWidth: true
			sourceComponent: modelData.isSeparator ? separator : button

			Component {
				id: separator
				Divider {}
			}

			Component {
				id: button
				ListItem {
					enabled: entry.modelData.enabled
					onClicked: {
						if (entry.modelData.hasChildren) {
							popup.stack = popup.stack.concat([entry.modelData])
						} else {
							entry.modelData.triggered()
							popup.visible = false
						}
					}

					BarText {
						visible: entry.modelData.buttonType !== QsMenuButtonType.None
						text: entry.modelData.buttonType === QsMenuButtonType.RadioButton
							? (entry.modelData.checkState === Qt.Checked ? "󰐾" : "󰄰")
							: (entry.modelData.checkState === Qt.Checked ? "󰄵" : "󰄱")
						color: entry.modelData.checkState === Qt.Checked ? Theme.accent : Theme.fgMuted
					}

					IconImage {
						visible: entry.modelData.icon !== ""
						source: entry.modelData.icon
						implicitSize: Theme.iconSize
					}

					BarText {
						Layout.fillWidth: true
						text: popup.cleanLabel(entry.modelData.text)
						muted: !entry.modelData.enabled
					}

					BarText {
						visible: entry.modelData.hasChildren
						text: "󰅂"
						muted: true
					}
				}
			}
		}
	}

	BarText {
		visible: opener.children.values.length === 0
		text: "No options"
		muted: true
	}
}
