import QtQuick 2.15
import Calamares 1.0

Presentation {
    id: presentation
    width: 800
    height: 600
    property int pauseLocks: 0
    property bool paused: pauseLocks > 0

    Timer {
        interval: 8000
        running: !presentation.paused
        repeat: true
        onTriggered: presentation.advance()
    }

    // Slide 1: Welcome
    Slide {
        Rectangle { anchors.fill: parent; color: "#0f0f1a" }
        Image {
            source: "background.png"; anchors.fill: parent
            fillMode: Image.PreserveAspectCrop; opacity: 0.3
            asynchronous: true; cache: true
        }
        Column {
            anchors.centerIn: parent; spacing: 16; width: parent.width * 0.8
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Welcome to NeOS")
                font.pixelSize: 36; font.bold: true; color: "white"
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Arch Linux, refined for everyone.")
                font.pixelSize: 18; color: "#a0a4b8"
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Your system is being installed. This will take a few minutes.")
                font.pixelSize: 14; color: "#6b7080"
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
        }
    }

    // Slide 2: Stability
    Slide {
        Rectangle { anchors.fill: parent; color: "#0f0f1a" }
        Column {
            anchors.centerIn: parent; spacing: 20; width: parent.width * 0.75
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Snapshot-Gated Stability")
                font.pixelSize: 28; font.bold: true; color: "#0078D4"
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("NeOS creates automatic Btrfs snapshots before every system update.\n\nIf anything goes wrong, roll back in seconds.\nNo more broken updates.")
                font.pixelSize: 16; color: "#c0c4d8"; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap; width: parent.width
                lineHeight: 1.4
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
        }
    }

    // Slide 3: Performance
    Slide {
        Rectangle { anchors.fill: parent; color: "#0f0f1a" }
        Column {
            anchors.centerIn: parent; spacing: 20; width: parent.width * 0.75
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Tuned for Speed")
                font.pixelSize: 28; font.bold: true; color: "#0078D4"
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("ZRAM swap compression keeps your system responsive.\nBBR congestion control for faster networking.\nOptimized I/O scheduling reduces lag on any hardware.")
                font.pixelSize: 16; color: "#c0c4d8"; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap; width: parent.width
                lineHeight: 1.4
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
        }
    }

    // Slide 4: Security
    Slide {
        Rectangle { anchors.fill: parent; color: "#0f0f1a" }
        Column {
            anchors.centerIn: parent; spacing: 20; width: parent.width * 0.75
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Secure by Default")
                font.pixelSize: 28; font.bold: true; color: "#0078D4"
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Firewall enabled out of the box.\nKernel hardening protects against common attacks.\nSystemd service sandboxing limits what programs can access.\n\nSecurity without the complexity.")
                font.pixelSize: 16; color: "#c0c4d8"; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap; width: parent.width
                lineHeight: 1.4
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
        }
    }

    // Slide 5: Hardware
    Slide {
        Rectangle { anchors.fill: parent; color: "#0f0f1a" }
        Column {
            anchors.centerIn: parent; spacing: 20; width: parent.width * 0.75
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Your Hardware, Handled")
                font.pixelSize: 28; font.bold: true; color: "#0078D4"
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("NeOS automatically detects your GPU, network, and peripherals.\nNVIDIA, AMD, and Intel drivers configured at first boot.\n\nWorks on real hardware and virtual machines alike.")
                font.pixelSize: 16; color: "#c0c4d8"; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap; width: parent.width
                lineHeight: 1.4
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
        }
    }

    // Slide 6: Getting Started
    Slide {
        Rectangle { anchors.fill: parent; color: "#0f0f1a" }
        Column {
            anchors.centerIn: parent; spacing: 20; width: parent.width * 0.75
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Almost There")
                font.pixelSize: 28; font.bold: true; color: "#0078D4"
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Once installation completes, you will have a fully configured\nKDE Plasma 6 desktop with everything you need.\n\nBrowse the web, manage files, install software from Discover,\nand enjoy a system that stays out of your way.")
                font.pixelSize: 16; color: "#c0c4d8"; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap; width: parent.width
                lineHeight: 1.4
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
        }
    }

    // Paused indicator
    Text {
        anchors { top: parent.top; right: parent.right; margins: 20 }
        text: qsTr("Paused"); visible: presentation.paused
        color: "#6b7080"; font.pixelSize: 12
        Accessible.role: Accessible.StaticText; Accessible.name: text
    }

    // Navigation
    Row {
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: 20 }
        spacing: 10

        Rectangle {
            width: 90; height: 36; radius: 6
            color: btnMouseArea.containsMouse ? "#252545" : "#1a1a2e"
            border.color: "#2a2a4a"
            Text { anchors.centerIn: parent; text: qsTr("Next"); color: "#c0c4d8"; font.pixelSize: 13 }
            MouseArea {
                id: btnMouseArea
                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: presentation.advance()
            }
            Accessible.role: Accessible.Button; Accessible.name: qsTr("Next Slide")
        }
    }

    Keys.onRightPressed: presentation.advance()
    Keys.onLeftPressed: presentation.advance()
    Keys.onSpacePressed: presentation.advance()
}
