import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import qs.style

PopupCard {
	id: popup
	cardWidth: 320

	readonly property PwNode sink: Pipewire.defaultAudioSink
	readonly property PwNode source: Pipewire.defaultAudioSource
	readonly property var audioNodes: Pipewire.nodes.values.filter(n => n.audio)
	readonly property var sinks: audioNodes.filter(n => n.isSink && !n.isStream)
	readonly property var sources: audioNodes.filter(n => !n.isSink && !n.isStream)
	readonly property var streams: audioNodes.filter(n => !n.isSink && n.isStream)

	function nodeName(n) {
		return n.description || n.nickname || n.name
	}

	function appName(n) {
		const p = n.properties ?? {}
		return p["application.name"] || p["media.name"] || nodeName(n)
	}

	// Bind every audio node while open so volumes and properties stay live.
	PwObjectTracker { objects: popup.visible ? popup.audioNodes : [] }

	BarText { text: "Audio"; font.bold: true; Layout.fillWidth: true }

	Divider {}

	// ── Output ──────────────────────────────────────────────
	BarText { text: "Output"; muted: true; small: true }

	VolumeRow {
		node: popup.sink
		visible: popup.sink !== null
	}

	Repeater {
		model: popup.sinks

		delegate: DeviceItem {
			isDefault: modelData === popup.sink
			label: popup.nodeName(modelData)
			onClicked: Pipewire.preferredDefaultAudioSink = modelData
		}
	}

	Divider {}

	// ── Input ───────────────────────────────────────────────
	BarText { text: "Input"; muted: true; small: true }

	VolumeRow {
		node: popup.source
		visible: popup.source !== null
		icon: "󰍬"
		mutedIcon: "󰍭"
	}

	Repeater {
		model: popup.sources

		delegate: DeviceItem {
			isDefault: modelData === popup.source
			label: popup.nodeName(modelData)
			onClicked: Pipewire.preferredDefaultAudioSource = modelData
		}
	}

	BarText {
		visible: popup.sources.length === 0
		text: "No input devices"
		muted: true
	}

	// ── Applications ────────────────────────────────────────
	Divider { visible: popup.streams.length > 0 }

	BarText {
		visible: popup.streams.length > 0
		text: "Applications"
		muted: true
		small: true
	}

	Repeater {
		model: popup.streams

		delegate: ColumnLayout {
			id: app
			required property PwNode modelData
			Layout.fillWidth: true
			spacing: 2

			BarText {
				Layout.fillWidth: true
				Layout.leftMargin: 2
				text: popup.appName(app.modelData)
				small: true
			}

			VolumeRow {
				node: app.modelData
				icon: "󰎆"
				mutedIcon: "󰎊"
			}
		}
	}

	component DeviceItem: ListItem {
		id: item
		required property PwNode modelData
		property bool isDefault: false
		property string label: ""

		BarText {
			Layout.fillWidth: true
			text: item.label
			color: item.isDefault ? Theme.info : Theme.fg
		}

		BarText {
			visible: item.isDefault
			text: "󰄬"
			color: Theme.info
		}
	}
}
