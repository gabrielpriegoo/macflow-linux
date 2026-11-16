import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Scope {
    id: root
    property bool open: false
    property string query: ""
    property var usage: ({})
    readonly property string usagePath: Quickshell.env("HOME") + "/.local/share/macflow/usage.json"

    IpcHandler {
        target: "spotlight"
        function toggle(): void { root.open = !root.open }
        function show(): void { root.open = true }
        function hide(): void { root.open = false }
    }

    FileView {
        id: usageFile
        path: root.usagePath
        printErrors: false
        onLoaded: { try { root.usage = JSON.parse(text()) } catch (e) { root.usage = ({}) } }
    }

    function fold(s) {
        return (s || "").toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "")
    }

    // Pontuacao: prefixo > inicio de palavra > substring; soma historico de uso.
    function score(q, e) {
        const n = fold(e.name)
        let s = 0
        if (n === q) s = 100
        else if (n.startsWith(q)) s = 80
        else if (n.includes(" " + q)) s = 65
        else if (n.includes(q)) s = 50
        else if (fold(e.genericName).includes(q)) s = 35
        else if (fold(e.comment).includes(q)) s = 20
        else if ((e.keywords || []).some(k => fold(k).includes(q))) s = 30
        if (s === 0) return 0
        const u = usage[e.id]
        return s + (u ? Math.min(15, u.n * 2) : 0)
    }

    function calc(q) {
        if (!/^[0-9+\-*\/().,%^ \t]+$/.test(q) || !/[0-9]/.test(q) || !/[+\-*\/%^]/.test(q)) return null
        try {
            const expr = q.replace(/,/g, ".").replace(/\^/g, "**").replace(/(\d+(?:\.\d+)?)%/g, "($1/100)")
            const v = eval(expr)
            if (typeof v !== "number" || !isFinite(v)) return null
            return String(+v.toPrecision(12))
        } catch (e) { return null }
    }

    readonly property var results: {
        const q = fold(query.trim())
        if (!q) return []
        const out = []
        const c = calc(query.trim())
        if (c !== null) out.push({ kind: "calc", title: "= " + c, subtitle: query.trim(), value: c })
        const apps = DesktopEntries.applications.values
            .filter(e => !e.noDisplay)
            .map(e => ({ e: e, s: score(q, e) }))
            .filter(x => x.s > 0)
            .sort((a, b) => b.s - a.s)
            .slice(0, 8)
        for (const a of apps) out.push({ kind: "app", title: a.e.name, subtitle: a.e.genericName || a.e.comment || "Aplicativo", entry: a.e })
        out.push({ kind: "web", title: "Pesquisar na web por “" + query.trim() + "”", subtitle: "Navegador", q: query.trim() })
        return out
    }

    function run(r) {
        if (!r) return
        if (r.kind === "app") {
            const u = usage
            u[r.entry.id] = { n: (u[r.entry.id] ? u[r.entry.id].n : 0) + 1, at: Date.now() }
            usage = u
            Quickshell.execDetached(["mkdir", "-p", Quickshell.env("HOME") + "/.local/share/macflow"])
            usageFile.setText(JSON.stringify(u))
            r.entry.execute()
        } else if (r.kind === "calc") {
            Quickshell.execDetached(["wl-copy", r.value])
        } else if (r.kind === "web") {
            Quickshell.execDetached(["xdg-open", "https://duckduckgo.com/?q=" + encodeURIComponent(r.q)])
        }
        root.open = false
    }

    LazyLoader {
        active: root.open
        PanelWindow {
            id: win
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "macflow-spotlight"

            MouseArea { anchors.fill: parent; onClicked: root.open = false }

            Rectangle {
                id: panel
                readonly property int w: Math.min(Theme.spotlightMaxWidth, win.width - 40)
                width: w
                x: Math.round((win.width - w) / 2)
                y: Math.round(win.height * Theme.spotlightTop)
                height: bar.height + (list.count > 0 ? 1 + list.height : 0)
                radius: Theme.spotlightRadius
                color: Theme.windowBg
                border.color: Theme.separator
                clip: true
                Behavior on height { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }

                MouseArea { anchors.fill: parent }

                Row {
                    id: bar
                    x: 14; width: parent.width - 28; height: 56; spacing: 10
                    Text { anchors.verticalCenter: parent.verticalCenter; text: "⌕"; font.pixelSize: 22; color: Theme.textDim }
                    TextInput {
                        id: input
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 40
                        font.pixelSize: 20
                        font.family: Theme.font
                        color: Theme.text
                        selectionColor: Theme.accent
                        focus: true
                        onTextChanged: { root.query = text; list.currentIndex = 0 }
                        Keys.onEscapePressed: root.open = false
                        Keys.onDownPressed: list.currentIndex = Math.min(list.count - 1, list.currentIndex + 1)
                        Keys.onUpPressed: list.currentIndex = Math.max(0, list.currentIndex - 1)
                        Keys.onReturnPressed: root.run(root.results[list.currentIndex])
                        Text {
                            visible: !input.text
                            text: "Spotlight"
                            font: input.font
                            color: Theme.textDim
                        }
                        Component.onCompleted: { text = ""; forceActiveFocus() }
                    }
                }

                Rectangle {
                    visible: list.count > 0
                    y: bar.height; width: parent.width; height: 1; color: Theme.separator
                }

                ListView {
                    id: list
                    y: bar.height + 1
                    width: parent.width
                    height: Math.min(440, count * 48 + 12)
                    topMargin: 6; bottomMargin: 6
                    model: root.results
                    currentIndex: 0
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: list.width - 12
                        x: 6; height: 48; radius: 8
                        color: ListView.isCurrentItem ? Theme.selected : "transparent"
                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 10; spacing: 12
                            Item {
                                width: 32; height: 32
                                Image {
                                    anchors.fill: parent
                                    visible: modelData.kind === "app"
                                    sourceSize: Qt.size(64, 64)
                                    source: modelData.entry ? Quickshell.iconPath(modelData.entry.icon, "application-x-executable") : ""
                                }
                                Text {
                                    anchors.centerIn: parent
                                    visible: modelData.kind !== "app"
                                    text: modelData.kind === "calc" ? "=" : "⌕"
                                    font.pixelSize: 22
                                    color: parent.parent.parent.ListView.isCurrentItem ? "white" : Theme.textDim
                                }
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: modelData.title
                                    font.pixelSize: 14; font.family: Theme.font
                                    color: ListView.isCurrentItem ? "white" : Theme.text
                                }
                                Text {
                                    text: modelData.subtitle
                                    font.pixelSize: 11; font.family: Theme.font
                                    color: ListView.isCurrentItem ? Qt.rgba(1, 1, 1, 0.75) : Theme.textDim
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: list.currentIndex = index
                            onClicked: root.run(modelData)
                        }
                    }
                }
            }
        }
    }
}
