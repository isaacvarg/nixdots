import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Qt.labs.folderlistmodel
import QtQuick
import QtQuick.Layouts
import qs.settings
import qs.style

Scope {
	id: root
	property bool open: false

	readonly property string layout: Settings.launcherLayout
	readonly property bool split: layout === "split"
	readonly property string home: Quickshell.env("HOME")
	readonly property string imagePath: Settings.launcherImagePath.replace(/^~(?=\/|$)/, home)
	property string folderPick: ""

	readonly property string image: {
		switch (Settings.launcherImage) {
		case "wallpaper": return wall.thumb || wall.path
		case "file": return imagePath
		case "folder": return folderPick
		default: return ""
		}
	}

	function pickFromFolder() {
		folderPick = folder.count > 0
			? folder.get(Math.floor(Math.random() * folder.count), "filePath")
			: ""
	}

	onOpenChanged: if (open && Settings.launcherImage === "folder") pickFromFolder()

	IpcHandler {
		target: "launcher"
		function toggle(): void { root.open = !root.open }
		function open(): void { root.open = true }
		function close(): void { root.open = false }
	}

	FileView {
		path: (Quickshell.env("XDG_CACHE_HOME") || root.home + "/.cache")
			+ "/skwd-wall-v2/last-wallpaper.json"
		watchChanges: true
		printErrors: false
		onFileChanged: reload()

		JsonAdapter {
			id: wall
			property string path: ""
			property string thumb: ""
		}
	}

	FolderListModel {
		id: folder
		folder: Settings.launcherImage === "folder" && root.imagePath !== ""
			? "file://" + root.imagePath
			: ""
		nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.bmp", "*.gif"]
		showDirs: false
		caseSensitive: false
		onCountChanged: if (root.folderPick === "") root.pickFromFolder()
	}

	LazyLoader {
		active: root.open

		PanelWindow {
			id: win
			screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null
			anchors { top: true; bottom: true; left: true; right: true }
			color: "transparent"
			exclusionMode: ExclusionMode.Ignore
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
			WlrLayershell.namespace: "quickshell-launcher"

			readonly property var results: Apps.search(input.text)
			readonly property var view: viewLoader.item

			function launch(entry) {
				if (!entry) return
				Apps.launch(entry)
				root.open = false
			}

			MouseArea {
				anchors.fill: parent
				onClicked: root.open = false
			}

			Rectangle {
				id: card
				width: Theme.launcherWidth
					+ (sideImage.shown ? Theme.launcherSideImageWidth + Theme.spacing : 0)
				height: content.implicitHeight + Theme.padding * 2
				x: (parent.width - width) / 2
				y: parent.height * 0.22
				color: Theme.popupBg
				border.color: Theme.border
				border.width: 1
				radius: Theme.radiusLarge

				MouseArea { anchors.fill: parent }

				RowLayout {
					id: content
					anchors.fill: parent
					anchors.margins: Theme.padding
					spacing: Theme.spacing

					LauncherImage {
						id: sideImage
						source: root.split ? root.image : ""
						Layout.preferredWidth: Theme.launcherSideImageWidth
						Layout.fillHeight: true
					}

					ColumnLayout {
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignTop
						spacing: Theme.spacingSmall

						LauncherImage {
							source: root.split ? "" : root.image
							Layout.fillWidth: true
							Layout.preferredHeight: Theme.launcherBannerHeight
							Layout.bottomMargin: Theme.spacingSmall
						}

						RowLayout {
							Layout.fillWidth: true
							Layout.preferredHeight: Theme.launcherRowHeight
							Layout.leftMargin: Theme.spacingSmall
							spacing: Theme.spacing

							BarText {
								text: "󰍉"
								color: Theme.accent
								font.pixelSize: Theme.iconSize + 3
							}

							TextInput {
								id: input
								Layout.fillWidth: true
								focus: true
								color: Theme.fg
								selectionColor: Theme.accent
								selectedTextColor: Theme.fgOnAccent
								font.family: Theme.fontFamily
								font.pixelSize: Theme.fontSize + 3
								clip: true

								onTextChanged: if (win.view) win.view.currentIndex = 0

								BarText {
									visible: input.text === ""
									text: "Search apps"
									muted: true
									font.pixelSize: input.font.pixelSize
								}

								Keys.onPressed: event => {
									const ctrl = event.modifiers & Qt.ControlModifier
									const key = event.key
									const v = win.view
									let handled = true

									if (key === Qt.Key_Escape) root.open = false
									else if (key === Qt.Key_Return || key === Qt.Key_Enter)
										win.launch(win.results[v.currentIndex])
									else if (key === Qt.Key_Tab) v.step(1)
									else if (key === Qt.Key_Backtab) v.step(-1)
									else if (key === Qt.Key_Down || (ctrl && (key === Qt.Key_J || key === Qt.Key_N)))
										v.move(0, 1)
									else if (key === Qt.Key_Up || (ctrl && (key === Qt.Key_K || key === Qt.Key_P)))
										v.move(0, -1)
									else if (key === Qt.Key_Right) handled = v.move(1, 0)
									else if (key === Qt.Key_Left) handled = v.move(-1, 0)
									else handled = false

									event.accepted = handled
								}
							}
						}

						Divider { visible: win.results.length > 0 || root.split }

						Loader {
							id: viewLoader
							Layout.fillWidth: true
							Layout.preferredHeight: item?.implicitHeight ?? 0
							visible: root.split || (item?.count ?? 0) > 0
							sourceComponent: root.layout === "grid" ? gridView : listView
						}

						BarText {
							visible: win.results.length === 0 && input.text !== ""
							Layout.fillWidth: true
							Layout.preferredHeight: Theme.launcherRowHeight
							horizontalAlignment: Text.AlignHCenter
							text: "No matches"
							muted: true
						}
					}
				}
			}

			Component {
				id: listView
				ResultsList {
					results: win.results
					fixedHeight: root.split
					onActivated: entry => win.launch(entry)
				}
			}

			Component {
				id: gridView
				ResultsGrid {
					results: win.results
					fixedHeight: root.split
					onActivated: entry => win.launch(entry)
				}
			}
		}
	}
}
