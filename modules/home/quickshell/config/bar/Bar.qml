import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import qs.settings
import qs.style
import qs.widgets

// A transparent strip across the top that holds three things: the centre
// blob, and a group of islands on each side. Settings.barLayout decides
// where the groups sit; everything is placed by x so a layout switch slides.
PanelWindow {
	id: root
	required property var modelData
	screen: modelData

	anchors { top: true; left: true; right: true }
	implicitHeight: Theme.barHeight + panelHeight + 24
	exclusionMode: ExclusionMode.Normal
	exclusiveZone: Theme.barHeight
	color: "transparent"
	WlrLayershell.keyboardFocus: calendarOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

	// Only the visible pieces take clicks; the gaps pass through.
	mask: Region {
		Region { item: blob }
		Region { item: leftGroup }
		Region { item: rightGroup }
	}

	readonly property string layout: Settings.barLayout
	readonly property bool merged: layout === "merged"
	readonly property real centre: width / 2
	readonly property real gap: Settings.islandGap
	readonly property real islandY: (Theme.barHeight - Theme.islandHeight) / 2

	// Merged: the blob grows equally both ways so the clock stays centred.
	readonly property real sideWidth: Math.max(leftGroup.width, rightGroup.width)
	readonly property real clockWidth: clock.width + Theme.blobPadding * 2

	readonly property real closedBody: merged
		? clockWidth + (gap + sideWidth) * 2
		: clockWidth
	readonly property real closedX: centre - closedBody / 2 - Theme.earRadius
	readonly property real openBody: Math.max(closedBody, calendar.width + Theme.panelPadding * 2)
	readonly property real panelHeight: calendar.height + Theme.panelPadding + 4

	property bool calendarOpen: false
	property real progress: 0

	function setCalendar(open) {
		if (open === calendarOpen) return
		calendarOpen = open
		if (open) calendar.reset()
		;(open ? closeAnim : openAnim).stop()
		;(open ? openAnim : closeAnim).start()
	}

	NumberAnimation {
		id: openAnim
		target: root; property: "progress"; to: 1
		duration: 420
		easing.type: Easing.OutBack; easing.overshoot: 0.7
	}

	NumberAnimation {
		id: closeAnim
		target: root; property: "progress"; to: 0
		duration: 260
		easing.type: Easing.InOutCubic
	}

	HyprlandFocusGrab {
		windows: [ root ]
		active: root.calendarOpen
		onCleared: root.setCalendar(false)
	}

	IdleInhibitor {
		window: root
		enabled: Caffeine.on
	}

	Blob {
		id: blob
		x: root.centre - width / 2
		bodyWidth: root.closedBody + (root.openBody - root.closedBody) * root.progress
		height: Theme.barHeight + root.panelHeight * Math.max(0, root.progress)
		radius: Theme.blobRadius + (Theme.blobRadiusOpen - Theme.blobRadius) * Math.min(1, root.progress)

		focus: root.calendarOpen
		Keys.onEscapePressed: root.setCalendar(false)

		Behavior on bodyWidth {
			enabled: root.progress === 0 && !openAnim.running
			NumberAnimation { duration: Theme.animDuration * 2; easing.type: Easing.OutCubic }
		}

		Clock {
			id: clock
			anchors.horizontalCenter: parent.horizontalCenter
			y: (Theme.barHeight - height) / 2
			onClicked: root.setCalendar(!root.calendarOpen)
		}

		Calendar {
			id: calendar
			readonly property real reveal: Math.max(0, Math.min(1, (root.progress - 0.3) / 0.7))
			x: (parent.width - width) / 2
			y: Theme.barHeight + 4 - (1 - reveal) * 12
			opacity: reveal
			scale: 0.96 + 0.04 * reveal
			enabled: root.calendarOpen
		}
	}

	Row {
		id: leftGroup
		y: root.islandY
		spacing: Theme.islandSpacing
		x: root.layout === "spread" ? Settings.edgeMargin
			: root.merged ? root.centre - clock.width / 2 - root.gap - width
			: root.closedX + blob.ear - root.gap - width

		Behavior on x { NumberAnimation { duration: Theme.animDuration * 2; easing.type: Easing.OutCubic } }

		Island {
			bare: root.merged
			Workspaces { screen: root.screen }
		}
	}

	Row {
		id: rightGroup
		y: root.islandY
		spacing: Theme.islandSpacing
		x: root.layout === "spread" ? root.width - Settings.edgeMargin - width
			: root.merged ? root.centre + clock.width / 2 + root.gap
			: root.closedX + blob.ear + root.closedBody + root.gap

		Behavior on x { NumberAnimation { duration: Theme.animDuration * 2; easing.type: Easing.OutCubic } }

		Island {
			bare: root.merged
			Tray {}
		}

		Island {
			bare: root.merged
			CaffeineWidget {}
			BluetoothWidget {}
			Volume {}
			Battery {}
			NotificationsWidget {}
		}

		Island {
			bare: root.merged
			PowerWidget {}
		}
	}
}
