import Quickshell.Services.Pipewire
import QtQuick
import qs.style

Chip {
	id: root
	readonly property PwNode sink: Pipewire.defaultAudioSink
	readonly property bool ready: sink?.audio !== undefined && sink?.audio !== null
	readonly property real volume: ready ? sink.audio.volume : 0
	readonly property bool muted: ready ? sink.audio.muted : true

	PwObjectTracker { objects: [ root.sink ] }

	active: popup.visible
	acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
	onClicked: mouse => {
		if (mouse.button === Qt.LeftButton) popup.visible = !popup.visible
		else if (ready) sink.audio.muted = !sink.audio.muted
	}
	onScrolled: wheel => {
		if (!ready) return
		const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
		sink.audio.volume = Math.max(0, Math.min(1, volume + step))
	}

	IconLabel {
		icon: root.muted ? "󰝟"
			: root.volume < 0.33 ? "󰕿"
			: root.volume < 0.66 ? "󰖀"
			: "󰕾"
		text: !root.ready ? "--"
			: root.muted ? "muted"
			: Math.round(root.volume * 100) + "%"
		color: root.active ? Theme.fgOnAccent
			: root.muted ? Theme.fgMuted
			: Theme.fg
	}

	VolumePopup {
		id: popup
		anchorItem: root
	}
}
