import Quickshell
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
	implicitHeight: Theme.barHeight
	color: "transparent"

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

	IdleInhibitor {
		window: root
		enabled: Caffeine.on
	}

	Blob {
		id: blob
		x: root.centre - width / 2
		bodyWidth: root.merged
			? root.clockWidth + (root.gap + root.sideWidth) * 2
			: root.clockWidth

		Behavior on bodyWidth { NumberAnimation { duration: Theme.animDuration * 2; easing.type: Easing.OutCubic } }

		Clock {
			id: clock
			anchors.centerIn: parent
		}
	}

	Row {
		id: leftGroup
		y: root.islandY
		spacing: Theme.islandSpacing
		x: root.layout === "spread" ? Settings.edgeMargin
			: root.merged ? root.centre - clock.width / 2 - root.gap - width
			: blob.x + blob.ear - root.gap - width

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
			: blob.x + blob.width - blob.ear + root.gap

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
