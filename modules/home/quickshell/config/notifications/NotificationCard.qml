import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import qs.settings
import qs.style

Rectangle {
	id: card

	required property Notification notification
	property bool toast: false

	readonly property bool critical: notification.urgency === NotificationUrgency.Critical
	readonly property string icon: {
		const i = notification.appIcon
		if (i === "") return ""
		if (i.startsWith("/") || i.includes("://")) return i
		return Quickshell.iconPath(i, true)
	}
	readonly property int timeout: critical ? 0
		: notification.expireTimeout > 0 ? notification.expireTimeout * 1000
		: Settings.notifTimeout

	implicitHeight: content.implicitHeight + Theme.padding * 2
	color: toast ? Theme.popupBg : hover.hovered ? Theme.chipBg : "transparent"
	border.color: critical ? Theme.critical : Theme.border
	border.width: toast || critical ? 1 : 0
	radius: Theme.radiusLarge

	Behavior on color { ColorAnimation { duration: Theme.animDuration } }

	HoverHandler { id: hover }

	Timer {
		running: card.toast && card.timeout > 0 && !hover.hovered
		interval: card.timeout
		onTriggered: Notifs.hidePopup(card.notification)
	}

	MouseArea {
		anchors.fill: parent
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: mouse => {
			if (mouse.button === Qt.RightButton) {
				card.notification.dismiss()
				return
			}
			const def = card.notification.actions.find(a => a.identifier === "default")
			if (def) def.invoke()
			else if (card.toast) Notifs.hidePopup(card.notification)
		}
	}

	RowLayout {
		id: content
		anchors.fill: parent
		anchors.margins: Theme.padding
		spacing: Theme.spacing

		Item {
			Layout.alignment: Qt.AlignTop
			implicitWidth: Theme.notifImageSize
			implicitHeight: Theme.notifImageSize

			Image {
				id: image
				anchors.fill: parent
				source: card.notification.image || card.icon
				sourceSize.width: Theme.notifImageSize
				sourceSize.height: Theme.notifImageSize
				fillMode: Image.PreserveAspectFit
				asynchronous: true
			}

			Rectangle {
				anchors.fill: parent
				visible: image.status !== Image.Ready
				radius: Theme.radius
				color: Theme.chipBgHover

				BarText {
					anchors.centerIn: parent
					text: "󰂚"
					color: card.critical ? Theme.critical : Theme.accent
					font.pixelSize: Theme.notifImageSize * 0.5
				}
			}
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 2

			RowLayout {
				Layout.fillWidth: true
				spacing: Theme.spacingSmall

				BarText {
					Layout.fillWidth: true
					text: card.notification.appName || "Notification"
					muted: true
					small: true
				}

				BarText {
					text: "󰅖"
					muted: !close.containsMouse
					color: close.containsMouse ? Theme.critical : Theme.fgMuted
					small: true

					MouseArea {
						id: close
						anchors.fill: parent
						anchors.margins: -4
						hoverEnabled: true
						cursorShape: Qt.PointingHandCursor
						onClicked: card.notification.dismiss()
					}
				}
			}

			BarText {
				Layout.fillWidth: true
				text: card.notification.summary
				font.bold: true
			}

			BarText {
				Layout.fillWidth: true
				visible: text !== ""
				text: card.notification.body
				textFormat: Text.StyledText
				wrapMode: Text.Wrap
				maximumLineCount: card.toast ? 4 : 2
				small: true
				color: Theme.fg
				opacity: 0.85
				onLinkActivated: link => Qt.openUrlExternally(link)
			}

			Flow {
				Layout.fillWidth: true
				Layout.topMargin: Theme.spacingSmall
				visible: buttons.count > 0
				spacing: Theme.spacingSmall

				Repeater {
					id: buttons
					model: card.notification.actions.filter(a => a.identifier !== "default")

					delegate: Chip {
						id: chip
						required property NotificationAction modelData
						onClicked: modelData.invoke()

						BarText {
							anchors.verticalCenter: parent.verticalCenter
							text: chip.modelData.text
							small: true
						}
					}
				}
			}
		}
	}
}
