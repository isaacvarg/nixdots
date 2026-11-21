pragma Singleton

import Quickshell
import QtQuick

Singleton {
	id: root

	readonly property var all: DesktopEntries.applications.values
		.filter(e => !e.noDisplay)
		.sort((a, b) => a.name.localeCompare(b.name))

	function match(query, text) {
		if (!text) return 0
		const t = text.toLowerCase()
		if (t === query) return 100
		if (t.startsWith(query)) return 90
		const at = t.indexOf(query)
		if (at > 0) return /[\s\-_.]/.test(t[at - 1]) ? 75 : 60

		let qi = 0, gaps = 0, last = -1
		for (let i = 0; i < t.length && qi < query.length; i++) {
			if (t[i] !== query[qi]) continue
			if (last >= 0) gaps += i - last - 1
			last = i
			qi++
		}
		return qi === query.length ? Math.max(1, 40 - gaps) : 0
	}

	function score(entry, query) {
		return Math.max(
			match(query, entry.name),
			match(query, entry.genericName) * 0.7,
			...entry.keywords.map(k => match(query, k) * 0.6),
			match(query, entry.comment) * 0.3
		)
	}

	function search(text) {
		const query = text.trim().toLowerCase()
		if (query === "") return all

		return all
			.map(e => ({ e, s: score(e, query) }))
			.filter(r => r.s > 0)
			.sort((a, b) => b.s - a.s || a.e.name.localeCompare(b.e.name))
			.map(r => r.e)
	}

	function launch(entry) {
		Quickshell.execDetached(["uwsm", "app", "--", entry.id + ".desktop"])
	}
}
