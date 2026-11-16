import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import qs.style

RowLayout {
	id: row

	required property PwNode node
	property string icon: "󰕾"
	property string mutedIcon: "󰝟"

	readonly property bool ready: node?.audio !== undefined && node?.audio !== null
	readonly property real volume: ready ? node.audio.volume : 0
	readonly property bool muted: ready ? node.audio.muted : true

	Layout.fillWidth: true
	spacing: Theme.spacingSmall

	Chip {
		padding: 6
		active: row.muted
		activeColor: Theme.chipBg
		onClicked: if (row.ready) row.node.audio.muted = !row.muted
		IconLabel {
			icon: row.muted ? row.mutedIcon : row.icon
			color: row.muted ? Theme.fgMuted : Theme.fg
		}
	}

	SliderBar {
		value: row.volume
		dimmed: row.muted
		onMoved: v => {
			if (!row.ready) return
			row.node.audio.volume = v
			if (row.muted && v > 0) row.node.audio.muted = false
		}
	}

	BarText {
		Layout.preferredWidth: 38
		horizontalAlignment: Text.AlignRight
		text: row.ready ? Math.round(row.volume * 100) + "%" : "--"
		muted: true
		small: true
	}
}
