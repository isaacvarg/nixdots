import Quickshell
import QtQuick
import QtQuick.Effects
import qs.settings
import qs.style

Item {
	id: root
	required property LockContext context
	readonly property bool typing: context.typing
	readonly property int fade: Theme.animDuration * 2

	Component.onCompleted: input.forceActiveFocus()

	LockBackground {
		id: background
		anchors.fill: parent
		visible: false
	}

	MultiEffect {
		anchors.fill: parent
		source: background
		autoPaddingEnabled: false
		blurEnabled: true
		blurMax: Theme.lockBlurMax
		blur: root.typing ? Settings.lockBlurTyping : Settings.lockBlur

		Behavior on blur { NumberAnimation { duration: root.fade; easing.type: Easing.OutCubic } }
	}

	Rectangle {
		anchors.fill: parent
		color: "black"
		opacity: root.typing ? Settings.lockDimTyping : Settings.lockDim

		Behavior on opacity { NumberAnimation { duration: root.fade } }
	}

	MouseArea {
		anchors.fill: parent
		onClicked: {
			root.context.wake()
			input.forceActiveFocus()
		}
	}

	SystemClock {
		id: clock
		precision: SystemClock.Minutes
	}

	Text {
		anchors.centerIn: parent
		text: Qt.formatDateTime(clock.date, "hh:mm AP")
		color: Theme.fg
		font.family: Theme.fontFamily
		font.pixelSize: Theme.lockClockSize
		font.weight: Font.Bold
		opacity: root.typing ? 0 : 1
		scale: root.typing ? 0.92 : 1

		Behavior on opacity { NumberAnimation { duration: root.fade } }
		Behavior on scale { NumberAnimation { duration: root.fade; easing.type: Easing.OutCubic } }
	}

	Column {
		anchors.centerIn: parent
		spacing: Theme.spacing
		opacity: root.typing ? 1 : 0
		scale: root.typing ? 1 : 0.92

		Behavior on opacity { NumberAnimation { duration: root.fade } }
		Behavior on scale { NumberAnimation { duration: root.fade; easing.type: Easing.OutCubic } }

		Rectangle {
			id: field
			width: Theme.lockInputWidth
			height: Theme.lockInputHeight
			radius: height / 2
			color: Qt.alpha(Theme.popupBg, 0.85)
			border.width: 2
			border.color: root.context.failed ? Theme.critical
				: root.context.checking ? Theme.fgMuted
				: Theme.accent

			Behavior on border.color { ColorAnimation { duration: Theme.animDuration } }

			transform: Translate { id: shakeOffset }

			SequentialAnimation {
				id: shake
				loops: 2
				NumberAnimation { target: shakeOffset; property: "x"; to: 10; duration: 40 }
				NumberAnimation { target: shakeOffset; property: "x"; to: -10; duration: 80 }
				NumberAnimation { target: shakeOffset; property: "x"; to: 0; duration: 40 }
			}

			Connections {
				target: root.context
				function onFailedChanged() { if (root.context.failed) shake.restart() }
			}

			TextInput {
				id: input
				anchors.fill: parent
				anchors.leftMargin: field.radius
				anchors.rightMargin: field.radius
				focus: true
				readOnly: root.context.checking
				echoMode: TextInput.Password
				passwordCharacter: "●"
				passwordMaskDelay: 0
				horizontalAlignment: TextInput.AlignHCenter
				verticalAlignment: TextInput.AlignVCenter
				color: Theme.fg
				selectionColor: Theme.accent
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize + 3
				font.letterSpacing: 2
				cursorVisible: false
				cursorDelegate: Item {}

				onTextChanged: root.context.currentText = text
				onAccepted: root.context.submit()
				Keys.onEscapePressed: root.context.cancel()

				Connections {
					target: root.context
					function onCurrentTextChanged() {
						if (input.text !== root.context.currentText) input.text = root.context.currentText
					}
				}
			}

			BarText {
				anchors.centerIn: parent
				visible: input.text === ""
				text: root.context.checking ? "checking…" : "password"
				muted: true
			}
		}

		BarText {
			anchors.horizontalCenter: parent.horizontalCenter
			text: root.context.message
			color: Theme.critical
			small: true
			opacity: root.context.failed ? 1 : 0

			Behavior on opacity { NumberAnimation { duration: Theme.animDuration } }
		}
	}
}
