import Quickshell
import QtQuick
import qs.style

Column {
	id: root

	property int weekStart: Locale.Monday
	readonly property date today: clock.date
	property int year: today.getFullYear()
	property int month: today.getMonth()
	readonly property bool onCurrentMonth: year === today.getFullYear() && month === today.getMonth()

	readonly property var days: {
		const first = new Date(year, month, 1)
		const offset = (first.getDay() - weekStart + 7) % 7
		const out = []
		for (let i = 0; i < 42; i++)
			out.push(new Date(year, month, 1 - offset + i))
		return out
	}

	function reset() {
		year = today.getFullYear()
		month = today.getMonth()
	}

	function shift(delta) {
		const d = new Date(year, month + delta, 1)
		year = d.getFullYear()
		month = d.getMonth()
	}

	function sameDay(a, b) {
		return a.getFullYear() === b.getFullYear()
			&& a.getMonth() === b.getMonth()
			&& a.getDate() === b.getDate()
	}

	width: Theme.calendarCellSize * 7
	spacing: Theme.spacingSmall

	SystemClock { id: clock; precision: SystemClock.Hours }

	WheelHandler {
		onWheel: e => root.shift(e.angleDelta.y > 0 ? -1 : 1)
	}

	Item {
		width: parent.width
		height: 32

		Row {
			anchors.left: parent.left
			anchors.leftMargin: 4
			anchors.verticalCenter: parent.verticalCenter
			spacing: Theme.spacingSmall

			BarText {
				id: monthName
				text: Qt.locale().standaloneMonthName(root.month, Locale.LongFormat)
				font.pixelSize: Theme.fontSize + 3
				font.bold: true
			}

			BarText {
				anchors.baseline: monthName.baseline
				text: root.year
				font.pixelSize: Theme.fontSize + 3
				muted: true
			}
		}

		Row {
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			spacing: 2

			NavButton {
				label: "Today"
				textColor: Theme.accent
				opacity: root.onCurrentMonth ? 0.45 : 1
				onClicked: root.reset()
			}
			NavButton { label: "󰅁"; onClicked: root.shift(-1) }
			NavButton { label: "󰅂"; onClicked: root.shift(1) }
		}
	}

	Grid {
		columns: 7

		Repeater {
			model: 7

			BarText {
				required property int index
				width: Theme.calendarCellSize
				height: 24
				horizontalAlignment: Text.AlignHCenter
				text: Qt.locale().dayName((root.weekStart + index) % 7, Locale.NarrowFormat)
				small: true
				muted: true
				font.bold: true
			}
		}
	}

	Grid {
		columns: 7

		Repeater {
			model: root.days

			Item {
				id: cell
				required property date modelData
				readonly property bool inMonth: modelData.getMonth() === root.month
				readonly property bool isToday: root.sameDay(modelData, root.today)

				width: Theme.calendarCellSize
				height: Theme.calendarCellSize

				Rectangle {
					anchors.centerIn: parent
					width: parent.width - 6
					height: width
					radius: width / 2
					color: cell.isToday ? Theme.accent
						: hover.hovered ? Theme.chipBgHover
						: "transparent"

					Behavior on color { ColorAnimation { duration: Theme.animDuration } }
				}

				BarText {
					anchors.centerIn: parent
					text: cell.modelData.getDate()
					font.bold: cell.isToday
					color: cell.isToday ? Theme.fgOnAccent : Theme.fg
					opacity: cell.inMonth ? 1 : 0.3
				}

				HoverHandler { id: hover }
			}
		}
	}

	component NavButton: Rectangle {
		id: btn
		property string label
		property color textColor: Theme.fg
		signal clicked()

		width: Math.max(height, text.implicitWidth + 16)
		height: 28
		radius: height / 2
		color: btnHover.hovered ? Theme.chipBgHover : "transparent"

		Behavior on color { ColorAnimation { duration: Theme.animDuration } }

		BarText {
			id: text
			anchors.centerIn: parent
			text: btn.label
			color: btn.textColor
		}

		HoverHandler { id: btnHover; cursorShape: Qt.PointingHandCursor }
		TapHandler { onTapped: btn.clicked() }
	}
}
