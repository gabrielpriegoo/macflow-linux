pragma Singleton
import Quickshell
import QtQuick

// Valores inspirados no tema "Lord Flow" (medidas observadas, codigo proprio).
Singleton {
    property bool dark: true
    readonly property color accent: "#0a84ff"
    readonly property color glass: dark ? Qt.rgba(0.11, 0.11, 0.13, 0.62) : Qt.rgba(1, 1, 1, 0.55)
    readonly property color windowBg: dark ? Qt.rgba(0.12, 0.12, 0.14, 0.86) : Qt.rgba(0.97, 0.97, 0.98, 0.9)
    readonly property color border: dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.12)
    readonly property color separator: dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.10)
    readonly property color text: dark ? "#ececf1" : "#1d1d1f"
    readonly property color textDim: dark ? Qt.rgba(0.93, 0.93, 0.95, 0.55) : Qt.rgba(0, 0, 0, 0.5)
    readonly property color selected: Qt.rgba(0.04, 0.52, 1, 0.9)
    readonly property string font: "Inter"

    // Dock
    readonly property int dockSize: 54
    readonly property int dockMagnifySize: 86
    readonly property int dockSpacing: 8
    readonly property int dockPad: 8
    readonly property int dockRadius: 20
    readonly property var dockPinned: [
        "org.kde.dolphin", "firefox", "org.kde.konsole",
        "org.kde.kate", "org.kde.systemsettings", "org.kde.discover"
    ]

    // Spotlight
    readonly property int spotlightMaxWidth: 720
    readonly property real spotlightTop: 0.16
    readonly property int spotlightRadius: 14
}
