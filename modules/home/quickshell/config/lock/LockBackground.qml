import Quickshell
import Quickshell.Io
import QtQuick

Item {
	id: root

	readonly property bool isVideo: wall.type === "video"
		|| /\.(mp4|webm|mkv|mov|avi)$/i.test(wall.path)
	readonly property bool videoReady: video.status === Loader.Ready
	readonly property string still: wall.type === "static" ? (wall.path || wall.thumb) : wall.thumb

	FileView {
		path: (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache")
			+ "/skwd-wall-v2/last-wallpaper.json"
		blockLoading: true
		printErrors: false

		JsonAdapter {
			id: wall
			property string path: ""
			property string thumb: ""
			property string type: "static"
		}
	}

	Image {
		anchors.fill: parent
		source: root.still
		fillMode: Image.PreserveAspectCrop
		sourceSize: Qt.size(root.width, root.height)
		visible: !(root.videoReady && video.item.playing)
	}

	Loader {
		id: video
		anchors.fill: parent
		active: root.isVideo && wall.path !== ""
		Component.onCompleted: setSource("VideoBackground.qml", { source: "file://" + wall.path })
	}
}
