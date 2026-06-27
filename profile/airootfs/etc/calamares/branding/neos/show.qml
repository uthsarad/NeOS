import QtQuick 2.15
import Calamares 1.0

// NeOS installer slideshow — Nations Trust Bank (NTB) palette:
//   NTB blue #0088CF, NTB cyan #0096D5, NTB magenta #EB008B on a premium dark base.
Presentation {
    id: presentation
    width: 800
    height: 600

    property int pauseLocks: 0
    property bool paused: pauseLocks > 0

    // ---- NTB brand palette -------------------------------------------------
    readonly property color cBg:      "#0b0e1a"
    readonly property color cTitle:   "#ffffff"
    readonly property color cBody:    "#c0c4d8"
    readonly property color cSubtle:  "#7a8099"
    readonly property color cBlue:    "#0088CF"
    readonly property color cCyan:    "#0096D5"
    readonly property color cMagenta: "#EB008B"

    Timer {
        interval: 8000
        running: !presentation.paused
        repeat: true
        onTriggered: presentation.advance()
    }

    // Reusable horizontal blue->magenta accent rule (the NTB signature gradient)
    component AccentRule: Rectangle {
        width: 90; height: 4; radius: 2
        anchors.horizontalCenter: parent.horizontalCenter
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: presentation.cBlue }
            GradientStop { position: 1.0; color: presentation.cMagenta }
        }
    }

    // Slide 1: Welcome
    Slide {
        Rectangle { anchors.fill: parent; color: presentation.cBg }
        Image {
            source: "background.png"; anchors.fill: parent
            fillMode: Image.PreserveAspectCrop; opacity: 0.30
            asynchronous: true; cache: true
        }
        Column {
            anchors.centerIn: parent; spacing: 16; width: parent.width * 0.8
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Welcome to NeOS")
                font.pixelSize: 38; font.bold: true; color: presentation.cTitle
                style: Text.Outline; styleColor: "black"
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
            AccentRule {}
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Arch Linux, refined for everyone.")
                font.pixelSize: 18; color: presentation.cCyan
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Your system is being installed. This will take a few minutes.")
                font.pixelSize: 14; color: presentation.cSubtle
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
        }
    }

    // Slide 2: Stability
    Slide {
        Rectangle { anchors.fill: parent; color: presentation.cBg }
        Column {
            anchors.centerIn: parent; spacing: 18; width: parent.width * 0.75
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Snapshot-Gated Stability")
                font.pixelSize: 28; font.bold: true; color: presentation.cTitle
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
            AccentRule {}
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("NeOS creates automatic Btrfs snapshots before every system update.\n\nIf anything goes wrong, roll back in seconds.\nNo more broken updates.")
                font.pixelSize: 16; color: presentation.cBody; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.4
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
        }
    }

    // Slide 3: Performance
    Slide {
        Rectangle { anchors.fill: parent; color: presentation.cBg }
        Column {
            anchors.centerIn: parent; spacing: 18; width: parent.width * 0.75
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Tuned for Speed")
                font.pixelSize: 28; font.bold: true; color: presentation.cTitle
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
            AccentRule {}
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("ZRAM swap compression keeps your system responsive.\nBBR congestion control for faster networking.\nOptimized I/O scheduling reduces lag on any hardware.")
                font.pixelSize: 16; color: presentation.cBody; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.4
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
        }
    }

    // Slide 4: Security
    Slide {
        Rectangle { anchors.fill: parent; color: presentation.cBg }
        Column {
            anchors.centerIn: parent; spacing: 18; width: parent.width * 0.75
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Secure by Default")
                font.pixelSize: 28; font.bold: true; color: presentation.cTitle
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
            AccentRule {}
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Firewall enabled out of the box.\nKernel hardening protects against common attacks.\nSystemd service sandboxing limits what programs can access.\n\nSecurity without the complexity.")
                font.pixelSize: 16; color: presentation.cBody; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.4
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
        }
    }

    // Slide 5: Hardware
    Slide {
        Rectangle { anchors.fill: parent; color: presentation.cBg }
        Column {
            anchors.centerIn: parent; spacing: 18; width: parent.width * 0.75
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Your Hardware, Handled")
                font.pixelSize: 28; font.bold: true; color: presentation.cTitle
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
            AccentRule {}
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("NeOS automatically detects your GPU, network, and peripherals.\nNVIDIA, AMD, and Intel drivers configured at first boot.\n\nWorks on real hardware and virtual machines alike.")
                font.pixelSize: 16; color: presentation.cBody; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.4
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
        }
    }

    // Slide 6: Getting Started
    Slide {
        Rectangle { anchors.fill: parent; color: presentation.cBg }
        Column {
            anchors.centerIn: parent; spacing: 18; width: parent.width * 0.75
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Almost There")
                font.pixelSize: 28; font.bold: true; color: presentation.cTitle
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
            AccentRule {}
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Once installation completes, you will have a fully configured\nKDE Plasma 6 desktop with everything you need.\n\nBrowse the web, manage files, install software from Discover,\nand enjoy a system that stays out of your way.")
                font.pixelSize: 16; color: presentation.cBody; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.4
                Accessible.role: Accessible.StaticText; Accessible.name: text
            }
        }
    }

    // Paused indicator
    Text {
        anchors { top: parent.top; right: parent.right; margins: 20 }
        text: "⏸ " + qsTr("Paused"); visible: presentation.paused
        color: presentation.cSubtle; font.pixelSize: 12
        style: Text.Outline; styleColor: "black"
        Accessible.role: Accessible.StaticText; Accessible.name: text
    }

    // Next button (NTB blue, magenta on hover/focus)
    Rectangle {
        id: btn; width: 110; height: 40; radius: 6
        anchors { bottom: parent.bottom; right: parent.right; margins: 20 }
        color: activeFocus || btnMouseArea.containsMouse ? presentation.cMagenta : presentation.cBlue
        activeFocusOnTab: true
        border.color: presentation.cCyan; border.width: activeFocus || btnMouseArea.containsMouse ? 2 : 0

        Behavior on scale { NumberAnimation { duration: 150 } }
        scale: activeFocus || btnMouseArea.containsMouse ? 1.08 : 1.0
        onActiveFocusChanged: activeFocus ? presentation.pauseLocks++ : presentation.pauseLocks--

        Text { anchors.centerIn: parent; text: qsTr("Next Slide"); color: "white"; font.pixelSize: 13; font.bold: true }
        MouseArea {
            id: btnMouseArea
            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: presentation.advance()
            onEntered: presentation.pauseLocks++
            onExited: presentation.pauseLocks--
        }
        Accessible.role: Accessible.Button; Accessible.name: qsTr("Next Slide")
        Keys.onReturnPressed: presentation.advance()
        Keys.onSpacePressed: presentation.advance()
    }

    // Global focus indicator
    Rectangle {
        anchors.fill: parent; color: "transparent"
        border.color: presentation.cCyan; border.width: presentation.activeFocus ? 2 : 0
        z: 100
    }

    Keys.onRightPressed: presentation.advance()
    Keys.onLeftPressed: presentation.advance()
    Keys.onSpacePressed: presentation.advance()
}
