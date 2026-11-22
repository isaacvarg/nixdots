import QtQuick
import QtMultimedia

Item {
	id: root
	property alias source: player.source
	readonly property bool playing: player.playbackState === MediaPlayer.PlayingState
		&& player.error === MediaPlayer.NoError

	MediaPlayer {
		id: player
		loops: MediaPlayer.Infinite
		videoOutput: output
		onSourceChanged: play()
	}

	VideoOutput {
		id: output
		anchors.fill: parent
		fillMode: VideoOutput.PreserveAspectCrop
		visible: root.playing
	}
}
