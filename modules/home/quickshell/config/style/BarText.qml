import QtQuick

Text {
	property bool muted: false
	property bool small: false

	color: muted ? Theme.fgMuted : Theme.fg
	font.family: Theme.fontFamily
	font.pixelSize: small ? Theme.fontSizeSmall : Theme.fontSize
	verticalAlignment: Text.AlignVCenter
	elide: Text.ElideRight
}
