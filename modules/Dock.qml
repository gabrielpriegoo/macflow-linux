import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: win
    readonly property int base: Theme.dockSize
    readonly property int peak: Theme.dockMagnifySize
    readonly property real sigma: base * 1.25

    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    implicitHeight: peak + Theme.dockPad * 2 + 18
    exclusiveZone: base + Theme.dockPad * 2 + 12
    color: "transparent"
    WlrLayershell.namespace: "macflow-dock"
    mask: Region { item: hitZone }

    property real mouseX: -1000
    property bool hovering: false

    Item {
        id: hitZone
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: pill.width + 24
        height: win.hovering ? win.height : pill.height + 12
    }

    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        height: win.base + Theme.dockPad * 2
        width: row.width + Theme.dockPad * 2
        radius: Theme.dockRadius
        color: Theme.glass
        border.color: Theme.border
        border.width: 1
        Behavior on width { NumberAnimation { duration: 70 } }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -40
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onPositionChanged: m => win.mouseX = mapToItem(row, m.x, m.y).x
            onEntered: win.hovering = true
            onExited: { win.hovering = false; win.mouseX = -1000 }
        }

        Row {
            id: row
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.dockPad
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.dockSpacing

            Repeater {
                model: Theme.dockPinned
                delegate: DockIcon {
                    required property string modelData
                    entry: DesktopEntries.heuristicLookup(modelData)
                    base: win.base
                    peak: win.peak
                    sigma: win.sigma
                    pointerX: win.mouseX
                    parentRow: row
                    visible: entry !== null
                }
            }
        }
    }
}
