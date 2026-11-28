import QtQuick
import QtQuick.Layouts
import qs.style

PopupCard {
	id: popup
	cardWidth: Theme.todoistWidth

	onVisibleChanged: {
		if (!visible) return
		Todoist.refresh()
		Todoist.loadFilters()
		input.forceActiveFocus()
	}

	RowLayout {
		Layout.fillWidth: true
		spacing: Theme.spacingSmall

		BarText { text: Todoist.view.name; font.bold: true; Layout.fillWidth: true }

		BarText {
			visible: Todoist.loading || Todoist.error !== ""
			text: Todoist.error !== "" ? Todoist.error : "…"
			color: Todoist.error !== "" ? Theme.critical : Theme.fgMuted
			small: true
		}

		Chip {
			onClicked: Todoist.refresh()
			IconLabel { icon: "󰑓" }
		}

		Chip {
			onClicked: {
				Todoist.openApp()
				popup.visible = false
			}
			IconLabel { icon: "󰏌" }
		}
	}

	Flow {
		Layout.fillWidth: true
		spacing: Theme.spacingSmall

		Repeater {
			model: [Todoist.today].concat(Todoist.filters)

			delegate: Chip {
				id: viewChip
				required property var modelData
				active: Todoist.view.query === modelData.query
				onClicked: Todoist.select(modelData)
				BarText {
					text: modelData.name
					small: true
					color: viewChip.active ? Theme.fgOnAccent : Theme.fg
				}
			}
		}
	}

	Divider {}

	Flickable {
		Layout.fillWidth: true
		Layout.preferredHeight: Math.min(list.implicitHeight, Theme.todoistListHeight)
		visible: Todoist.tasks.length > 0
		contentHeight: list.implicitHeight
		clip: true
		boundsBehavior: Flickable.StopAtBounds

		ColumnLayout {
			id: list
			width: parent.width
			spacing: 0

			Repeater {
				model: Todoist.tasks

				delegate: RowLayout {
					required property var modelData
					Layout.fillWidth: true
					Layout.preferredHeight: Theme.listItemHeight
					Layout.leftMargin: Theme.spacingSmall
					Layout.rightMargin: Theme.spacingSmall
					spacing: Theme.spacingSmall

					BarText {
						text: check.hovered ? "󰄵" : "󰄱"
						font.pixelSize: Theme.iconSize
						// API priority 4 = UI p1
						color: modelData.priority === 4 ? Theme.critical
							: modelData.priority === 3 ? Theme.warn
							: modelData.priority === 2 ? Theme.info
							: Theme.fgMuted

						HoverHandler { id: check; cursorShape: Qt.PointingHandCursor }
						TapHandler { onTapped: Todoist.complete(modelData.id) }
					}

					ListItem {
						Layout.fillWidth: true
						onClicked: {
							Todoist.openTask(modelData.id)
							popup.visible = false
						}

						BarText { text: modelData.content; Layout.fillWidth: true }

						BarText {
							visible: !!modelData.due
							text: modelData.due?.string ?? ""
							muted: true
							small: true
						}
					}
				}
			}
		}
	}

	BarText {
		visible: Todoist.tasks.length === 0 && !Todoist.loading
		Layout.fillWidth: true
		Layout.preferredHeight: Theme.listItemHeight
		horizontalAlignment: Text.AlignHCenter
		text: "Nothing here"
		muted: true
	}

	Divider {}

	RowLayout {
		Layout.fillWidth: true
		Layout.preferredHeight: Theme.listItemHeight
		Layout.leftMargin: Theme.spacingSmall
		spacing: Theme.spacingSmall

		BarText { text: "󰐕"; color: Theme.accent; font.pixelSize: Theme.iconSize }

		TextInput {
			id: input
			Layout.fillWidth: true
			color: Theme.fg
			selectionColor: Theme.accent
			selectedTextColor: Theme.fgOnAccent
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize
			clip: true
			enabled: !busy

			property bool busy: false

			BarText {
				visible: input.text === ""
				text: "Add to Inbox"
				muted: true
			}

			Keys.onEscapePressed: popup.visible = false
			onAccepted: {
				const text = input.text.trim()
				if (text === "") return
				busy = true
				Todoist.add(text, ok => {
					busy = false
					if (ok) input.text = ""
					input.forceActiveFocus()
				})
			}
		}
	}
}
