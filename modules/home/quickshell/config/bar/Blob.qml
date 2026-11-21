import QtQuick
import QtQuick.Shapes
import qs.style

// The centre piece: hangs from the top edge of the screen, rounded at the
// bottom, and flares into the edge with a concave ear on each side.
//
//   ear ╮                      ╭ ear
//        │      bodyWidth      │
//        ╰─────────────────────╯
//
// width includes both ears; set bodyWidth and the shape follows.
Item {
	id: root

	default property alias content: body.data
	property real bodyWidth: 120
	property color color: Theme.islandBg
	readonly property real ear: Theme.earRadius
	readonly property real corner: Math.min(Theme.blobRadius, height / 2)

	width: bodyWidth + ear * 2
	height: Theme.barHeight

	Shape {
		anchors.fill: parent
		preferredRendererType: Shape.CurveRenderer

		ShapePath {
			strokeWidth: -1
			fillColor: root.color

			startX: 0; startY: 0
			PathArc { x: root.ear; y: root.ear; radiusX: root.ear; radiusY: root.ear }
			PathLine { x: root.ear; y: root.height - root.corner }
			PathArc {
				x: root.ear + root.corner; y: root.height
				radiusX: root.corner; radiusY: root.corner
				direction: PathArc.Counterclockwise
			}
			PathLine { x: root.ear + root.bodyWidth - root.corner; y: root.height }
			PathArc {
				x: root.ear + root.bodyWidth; y: root.height - root.corner
				radiusX: root.corner; radiusY: root.corner
				direction: PathArc.Counterclockwise
			}
			PathLine { x: root.ear + root.bodyWidth; y: root.ear }
			PathArc { x: root.width; y: 0; radiusX: root.ear; radiusY: root.ear }
			PathLine { x: 0; y: 0 }
		}
	}

	Item {
		id: body
		x: root.ear
		width: root.bodyWidth
		height: root.height
	}
}
