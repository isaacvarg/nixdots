pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.settings

Singleton {
	id: root

	readonly property string api: "https://api.todoist.com/api/v1"
	property string token: ""
	readonly property bool ready: token !== ""

	// "today | overdue" matches app's Today view
	readonly property var today: ({ name: "Today", query: "today | overdue" })
	property var view: today
	property var filters: []
	property var tasks: []
	property bool loading: false
	property string error: ""

	function openApp() {
		Quickshell.execDetached(["flatpak", "run", Settings.todoistApp])
	}

	function openTask(id) {
		Quickshell.execDetached(["xdg-open", "todoist://task?id=" + id])
	}

	function select(v) {
		view = v
		tasks = []
		refresh()
	}

	function refresh() {
		if (!ready) return
		loading = true
		request("GET", "/tasks/filter?limit=200&query=" + encodeURIComponent(view.query), null, (ok, res) => {
			loading = false
			if (!ok) return
			tasks = res.results.slice().sort((a, b) => b.priority - a.priority
				|| (a.due?.date ?? "9").localeCompare(b.due?.date ?? "9"))
		})
	}

	function complete(id) {
		tasks = tasks.filter(t => t.id !== id)
		request("POST", "/tasks/" + id + "/close", null, ok => { if (!ok) refresh() })
	}

	function loadFilters() {
		if (!ready) return
		const body = "sync_token=*&resource_types=" + encodeURIComponent('["filters"]')
		request("POST", "/sync", body, (ok, res) => {
			if (ok) filters = res.filters
				.filter(f => !f.is_deleted)
				.sort((a, b) => a.item_order - b.item_order)
		}, "application/x-www-form-urlencoded")
	}

	// Quick add: lands in Inbox, parses dates, p1, #Project, @label
	function add(text, done) {
		request("POST", "/tasks/quick", JSON.stringify({ text: text }), ok => {
			if (ok) refresh()
			done(ok)
		})
	}

	function request(method, path, body, cb, contentType) {
		const xhr = new XMLHttpRequest()
		xhr.onreadystatechange = () => {
			if (xhr.readyState !== XMLHttpRequest.DONE) return
			const ok = xhr.status >= 200 && xhr.status < 300
			error = ok ? "" : xhr.status === 0 ? "offline" : "error " + xhr.status
			let res = null
			if (ok && xhr.responseText) {
				try { res = JSON.parse(xhr.responseText) } catch (e) {}
			}
			cb(ok, res)
		}
		xhr.open(method, api + path)
		xhr.setRequestHeader("Authorization", "Bearer " + token)
		if (body !== null) xhr.setRequestHeader("Content-Type", contentType ?? "application/json")
		xhr.send(body)
	}

	onReadyChanged: if (ready) { loadFilters(); refresh() }

	FileView {
		id: tokenFile
		path: Settings.todoistTokenFile
		printErrors: false
		onLoaded: root.token = text().trim()
	}

	Timer {
		interval: 30000
		running: !root.ready
		repeat: true
		onTriggered: tokenFile.reload()
	}

	Timer {
		interval: Settings.todoistRefresh
		running: root.ready
		repeat: true
		onTriggered: root.refresh()
	}
}
