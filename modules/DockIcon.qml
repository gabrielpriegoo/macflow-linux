import Quickshell
import QtQuick

Item {
    id: root
    property var entry
    property real base
    property real peak
    property real sigma
    property real pointerX
    property Item parentRow

    // Gaussiana: 0 longe do mouse, 1 em cima do icone.
    readonly property real dist: pointerX - (x + width / 2)
    readonly property real influence: pointerX < -500 ? 0 : Math.exp(-(dist * dist) / (2 * sigma * sigma))
    property real size: base + (peak - base) * influence

    width: size
    height: size
    anchors.bottom: parent ? parent.bottom : undefined
    Behavior on size { NumberAnimation { duration: 60; easing.type: Easing.OutQuad } }

    property real bounce: 0

    Image {
        id: icon
        width: root.size
        height: root.size
        y: -root.bounce
        sourceSize: Qt.size(128, 128)
        smooth: true
        mipmap: true
        source: root.entry ? Quickshell.iconPath(root.entry.icon, "application-x-executable") : ""
    }

    Rectangle { // ponto de app aberto (liga ao ToplevelManager depois)
        visible: false
        width: 4; height: 4; radius: 2
        color: Theme.text
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height + 3
    }

    // Rotulo ao passar o mouse
    Rectangle {
        visible: root.influence > 0.85 && root.entry
        anchors.horizontalCenter: parent.horizontalCenter
        y: -height - 14
        height: 26
        width: label.implicitWidth + 20
        radius: 7
        color: Theme.windowBg
        border.color: Theme.border
        Text {
            id: label
            anchors.centerIn: parent
            text: root.entry ? root.entry.name : ""
            color: Theme.text
            font.pixelSize: 12
            font.family: Theme.font
        }
    }

    SequentialAnimation {
        id: bounceAnim
        loops: 2
        NumberAnimation { target: root; property: "bounce"; to: 18; duration: 220; easing.type: Easing.OutQuad }
        NumberAnimation { target: root; property: "bounce"; to: 0; duration: 220; easing.type: Easing.InQuad }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: { if (root.entry) { root.entry.execute(); bounceAnim.start() } }
    }
}
