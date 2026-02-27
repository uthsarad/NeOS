import QtQuick 2.0; import Calamares 1.0

Presentation {
    id: presentation; width: 800; height: 600
    property int pauseLocks: 0; property bool paused: pauseLocks > 0

    Timer { interval: 5000; running: !presentation.paused; repeat: true; onTriggered: presentation.advance() }

    Slide {
        Rectangle { anchors.fill: parent; color: "#2c3e50" } // Fallback BG
        Image {
            source: "background.png"; anchors.fill: parent; fillMode: Image.PreserveAspectCrop
            asynchronous: true; cache: true // UX: Smooth loading
        }
        Text {
            anchors.centerIn: parent; text: qsTr("Welcome to NeOS")
            font.pixelSize: 32; color: "white"; style: Text.Outline; styleColor: "black"
            Accessible.role: Accessible.StaticText; Accessible.name: text
        }
    }

    Text { // Paused Indicator
        anchors { top: parent.top; right: parent.right; margins: 20 }
        text: "⏸ " + qsTr("Paused"); visible: presentation.paused
        color: "white"; style: Text.Outline; styleColor: "black"
        Accessible.role: Accessible.StaticText; Accessible.name: text
    }

    Rectangle { // Next Button
        id: btn; width: 100; height: 40; radius: 4
        anchors { bottom: parent.bottom; right: parent.right; margins: 20 }
        color: activeFocus ? "#3daee9" : "#444"
        activeFocusOnTab: true // A11y: Keyboard nav
        border.color: "#3daee9"; border.width: activeFocus ? 2 : 0

        Behavior on scale { NumberAnimation { duration: 150 } }
        scale: activeFocus ? 1.1 : 1.0
        onActiveFocusChanged: activeFocus ? presentation.pauseLocks++ : presentation.pauseLocks--

        Text { anchors.centerIn: parent; text: qsTr("Next Slide"); color: "white" }
        MouseArea {
            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: presentation.advance()
            onEntered: presentation.pauseLocks++; onExited: presentation.pauseLocks--
        }
        Accessible.role: Accessible.Button; Accessible.name: qsTr("Next Slide")
        Keys.onReturnPressed: presentation.advance(); Keys.onSpacePressed: presentation.advance()
    }

    // Global Nav & Focus
    Rectangle {
        anchors.fill: parent; color: "transparent"
        border.color: "#3daee9"; border.width: presentation.activeFocus ? 2 : 0
        z: 100
    }
    Keys.onRightPressed: presentation.advance(); Keys.onLeftPressed: presentation.advance()
    Keys.onSpacePressed: presentation.advance()
}
