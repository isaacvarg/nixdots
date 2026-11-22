import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import QtQuick
import qs.settings

Scope {
	id: root
	signal unlocked()

	property bool preview: false
	property string currentText: ""
	property bool typing: false
	property bool checking: false
	property bool failed: false
	property string message: ""

	onCurrentTextChanged: {
		if (currentText !== "") {
			failed = false
			typing = true
		}
		idle.restart()
	}

	function wake(): void {
		typing = true
		idle.restart()
	}

	function submit(): void {
		if (currentText === "" || checking) return
		checking = true
		failed = false
		pam.start()
	}

	function cancel(): void {
		if (!typing && preview) Qt.quit()
		currentText = ""
		typing = false
	}

	Timer {
		id: idle
		interval: Settings.lockIdleTimeout
		running: root.typing && !root.checking
		onTriggered: root.cancel()
	}

	FileView {
		id: pamFile
		path: "/etc/pam.d/quickshell-lock"
		blockLoading: true
		printErrors: false
	}

	PamContext {
		id: pam
		config: pamFile.loaded ? "quickshell-lock" : "login"

		onPamMessage: {
			if (responseRequired) respond(root.currentText)
		}

		onCompleted: result => {
			root.checking = false
			if (result === PamResult.Success) {
				root.unlocked()
				return
			}
			root.currentText = ""
			root.message = "wrong password"
			root.failed = true
		}

		onError: error => {
			root.checking = false
			root.currentText = ""
			root.message = "auth error"
			root.failed = true
		}
	}
}
