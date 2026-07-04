import QtQuick 2.15
import Calamares 1.0

// NeOS installer slideshow — Ubuntu-inspired polished design.
// Smooth crossfade transitions between slides, NTB brand palette on a dark premium base.
Presentation {
    id: presentation
    width: 800
    height: 600

    property int pauseLocks: 0
    property bool paused: pauseLocks > 0
    property int currentSlide: 0
    property int totalSlides: 6

    // ---- NTB brand palette -------------------------------------------------
    readonly property color cBg:      "#0b0e1a"
    readonly property color cCard:    "#11172e"
    readonly property color cBorder:  "#1c2444"
    readonly property color cTitle:   "#ffffff"
    readonly property color cBody:    "#c0c4d8"
    readonly property color cSubtle:  "#7a8099"
    readonly property color cBlue:    "#0088CF"
    readonly property color cCyan:    "#0096D5"
    readonly property color cMagenta: "#EB008B"
    readonly property color cGreen:   "#22c55e"

    // Auto-advance timer
    Timer {
        interval: 10000
        running: !presentation.paused
        repeat: true
        onTriggered: presentation.advance()
    }

    // ---- Reusable accent gradient bar (NTB signature) ----------------------
    component AccentBar: Rectangle {
        width: 100; height: 3; radius: 2
        anchors.horizontalCenter: parent.horizontalCenter
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: presentation.cBlue }
            GradientStop { position: 0.5; color: presentation.cCyan }
            GradientStop { position: 1.0; color: presentation.cMagenta }
        }
    }

    // ---- Slide content (fades in/out via opacity animation) ----------------
    Rectangle {
        id: slideContainer
        anchors.fill: parent; color: presentation.cBg
        // Keyboard-focus feedback: cyan border when the presentation has focus
        // so keyboard users can see the slideshow is focused/navigable.
        border.color: presentation.cCyan
        border.width: presentation.activeFocus ? 2 : 0

        property var slideOpacity: [1, 0, 0, 0, 0, 0]
        Behavior on slideOpacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }

        function showSlide(index) {
            for (var i = 0; i < slideOpacity.length; i++) {
                slideOpacity[i] = (i === index) ? 1 : 0;
            }
        }

        // ---- Shared background with subtle gradient overlay ----------------
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#0a0e1a" }
                GradientStop { position: 0.5; color: "#0d1224" }
                GradientStop { position: 1.0; color: "#16203a" }
            }
        }

        // Decorative radial glow behind content
        Rectangle {
            x: parent.width / 2 - 300; y: parent.height / 2 - 300
            width: 600; height: 600; radius: 300
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0.53, 0.81, 0.08) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // ====== SLIDE 1: Welcome ==========================================
        Item {
            anchors.fill: parent; opacity: slideContainer.slideOpacity[0]
            Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }

            Column {
                anchors.centerIn: parent; spacing: 16; width: parent.width * 0.78
                Item { width: 1; height: 40 }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Welcome to NeOS")
                    font.pixelSize: 42; font.bold: true; color: presentation.cTitle
                    style: Text.Outline; styleColor: Qt.rgba(0,0,0,0.3)
                    Accessible.role: Accessible.StaticText; Accessible.name: text
                }

                AccentBar {}

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Arch Linux, refined for everyone.")
                    font.pixelSize: 20; color: presentation.cCyan
                    font.weight: Font.Light
                    Accessible.role: Accessible.StaticText; Accessible.name: text
                }

                Item { width: 1; height: 8 }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Your system is being installed. This will take a few minutes.")
                    font.pixelSize: 15; color: presentation.cSubtle
                    horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; width: parent.width * 0.85
                    lineHeight: 1.5
                    Accessible.role: Accessible.StaticText; Accessible.name: text
                }

                // Animated dots indicator
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter; spacing: 8
                    topPadding: 12
                    Repeater {
                        model: 3
                        Rectangle {
                            width: 8; height: 8; radius: 4
                            color: presentation.cBlue
                            opacity: 0.3 + (0.7 * (Math.sin(Date.now() / 300 + index * 2) * 0.5 + 0.5))
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }
                    }
                }
            }
        }

        // ====== SLIDE 2: Snapshot Protection ==============================
        Item {
            anchors.fill: parent; opacity: slideContainer.slideOpacity[1]
            Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }

            Column {
                anchors.centerIn: parent; spacing: 18; width: parent.width * 0.72
                Item { width: 1; height: 20 }

                // Icon placeholder
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 64; height: 64; radius: 32
                    color: Qt.rgba(0, 0.53, 0.81, 0.15)
                    border.color: presentation.cBorder; border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "↺"; color: presentation.cCyan
                        font.pixelSize: 30; font.bold: true
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Snapshot-Gated Stability")
                    font.pixelSize: 28; font.bold: true; color: presentation.cTitle
                    Accessible.role: Accessible.StaticText; Accessible.name: text
                }
                AccentBar {}

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("NeOS creates automatic Btrfs snapshots before every system update.\n\nIf anything goes wrong, roll back in seconds.\nNo more broken updates.")
                    font.pixelSize: 16; color: presentation.cBody; horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.6
                    Accessible.role: Accessible.StaticText; Accessible.name: text
                }
            }
        }

        // ====== SLIDE 3: Performance ====================================
        Item {
            anchors.fill: parent; opacity: slideContainer.slideOpacity[2]
            Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }

            Column {
                anchors.centerIn: parent; spacing: 18; width: parent.width * 0.72
                Item { width: 1; height: 20 }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 64; height: 64; radius: 32
                    color: Qt.rgba(0.13, 0.77, 0.37, 0.12)
                    border.color: Qt.rgba(0.13, 0.77, 0.37, 0.3); border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "⚡"; color: presentation.cGreen
                        font.pixelSize: 28
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Tuned for Speed")
                    font.pixelSize: 28; font.bold: true; color: presentation.cTitle
                    Accessible.role: Accessible.StaticText; Accessible.name: text
                }
                AccentBar {}

                // Feature cards
                Column { spacing: 10; width: parent.width; anchors.horizontalCenter: parent.horizontalCenter; topPadding: 8
                    Repeater {
                        model: [
                            qsTr("ZRAM swap compression keeps your system responsive"),
                            qsTr("BBR congestion control for faster networking"),
                            qsTr("Optimized I/O scheduling reduces lag on any hardware")
                        ]
                        Rectangle {
                            width: parent.width; height: 36; radius: 8
                            color: presentation.cCard; border.color: presentation.cBorder; border.width: 1
                            Text {
                                anchors.verticalCenter: parent.verticalCenter; x: 14
                                text: "•  " + modelData; color: presentation.cBody
                                font.pixelSize: 14
                            }
                        }
                    }
                }
            }
        }

        // ====== SLIDE 4: Security =======================================
        Item {
            anchors.fill: parent; opacity: slideContainer.slideOpacity[3]
            Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }

            Column {
                anchors.centerIn: parent; spacing: 18; width: parent.width * 0.72
                Item { width: 1; height: 20 }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 64; height: 64; radius: 32
                    color: Qt.rgba(0.92, 0.03, 0.55, 0.12)
                    border.color: Qt.rgba(0.92, 0.03, 0.55, 0.3); border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "🛡"; color: presentation.cMagenta
                        font.pixelSize: 28
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Secure by Default")
                    font.pixelSize: 28; font.bold: true; color: presentation.cTitle
                    Accessible.role: Accessible.StaticText; Accessible.name: text
                }
                AccentBar {}

                Column { spacing: 10; width: parent.width; anchors.horizontalCenter: parent.horizontalCenter; topPadding: 8
                    Repeater {
                        model: [
                            qsTr("Firewall enabled out of the box"),
                            qsTr("Kernel hardening protects against common attacks"),
                            qsTr("Systemd service sandboxing limits program access"),
                            qsTr("Security without the complexity")
                        ]
                        Rectangle {
                            width: parent.width; height: 36; radius: 8
                            color: presentation.cCard; border.color: presentation.cBorder; border.width: 1
                            Text {
                                anchors.verticalCenter: parent.verticalCenter; x: 14
                                text: "•  " + modelData; color: presentation.cBody
                                font.pixelSize: 14
                            }
                        }
                    }
                }
            }
        }

        // ====== SLIDE 5: Hardware =======================================
        Item {
            anchors.fill: parent; opacity: slideContainer.slideOpacity[4]
            Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }

            Column {
                anchors.centerIn: parent; spacing: 18; width: parent.width * 0.72
                Item { width: 1; height: 20 }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 64; height: 64; radius: 32
                    color: Qt.rgba(0, 0.53, 0.81, 0.15)
                    border.color: presentation.cBorder; border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "💻"; color: presentation.cBlue
                        font.pixelSize: 28
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Your Hardware, Handled")
                    font.pixelSize: 28; font.bold: true; color: presentation.cTitle
                    Accessible.role: Accessible.StaticText; Accessible.name: text
                }
                AccentBar {}

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("NeOS automatically detects your GPU, network, and peripherals.\nNVIDIA, AMD, and Intel drivers configured at first boot.\n\nWorks on real hardware and virtual machines alike.")
                    font.pixelSize: 16; color: presentation.cBody; horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.6
                    Accessible.role: Accessible.StaticText; Accessible.name: text
                }
            }
        }

        // ====== SLIDE 6: Getting Started ===============================
        Item {
            anchors.fill: parent; opacity: slideContainer.slideOpacity[5]
            Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }

            Column {
                anchors.centerIn: parent; spacing: 18; width: parent.width * 0.72
                Item { width: 1; height: 20 }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 64; height: 64; radius: 32
                    color: Qt.rgba(0.92, 0.03, 0.55, 0.12)
                    border.color: Qt.rgba(0.92, 0.03, 0.55, 0.3); border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "🚀"; color: presentation.cMagenta
                        font.pixelSize: 28
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Almost There")
                    font.pixelSize: 28; font.bold: true; color: presentation.cTitle
                    Accessible.role: Accessible.StaticText; Accessible.name: text
                }
                AccentBar {}

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Once installation completes, you will have a fully configured\nKDE Plasma 6 desktop with everything you need.\n\nBrowse the web, manage files, install software from Discover,\nand enjoy a system that stays out of your way.")
                    font.pixelSize: 16; color: presentation.cBody; horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.6
                    Accessible.role: Accessible.StaticText; Accessible.name: text
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter; topPadding: 12
                    text: qsTr("Thank you for choosing NeOS!")
                    font.pixelSize: 14; color: presentation.cSubtle; font.italic: true
                    Accessible.role: Accessible.StaticText; Accessible.name: text
                }
            }
        }

        // ---- Slide indicator dots (bottom-centre) --------------------------
        Row {
            anchors { bottom: parent.bottom; bottomMargin: 24; horizontalCenter: parent.horizontalCenter }
            spacing: 10
            Repeater {
                model: totalSlides
                Rectangle {
                    width: 8; height: 8; radius: 4
                    color: index === currentSlide ? presentation.cBlue : "#2a3354"
                    Behavior on color { ColorAnimation { duration: 300 } }
                    Behavior on width { NumberAnimation { duration: 300 } }
                    width: index === currentSlide ? 24 : 8
                }
            }
        }
    }

    // ---- Track slide changes and animate container -------------------------
    property bool internalAdvance: false
    onCurrentSlideChanged: {
        if (!internalAdvance) return;
        slideContainer.showSlide(currentSlide);
    }

    function advance() {
        internalAdvance = true;
        currentSlide = (currentSlide + 1) % totalSlides;
        slideContainer.showSlide(currentSlide);
        internalAdvance = false;
    }

    // ---- Paused indicator (top-right) -------------------------------------
    Rectangle {
        anchors { top: parent.top; right: parent.right; margins: 16 }
        visible: presentation.paused
        color: Qt.rgba(0,0,0,0.5); radius: 6
        height: 26; width: 80
        Text {
            anchors.centerIn: parent
            text: "⏸ " + qsTr("Paused"); color: presentation.cSubtle
            font.pixelSize: 11
            Accessible.role: Accessible.StaticText; Accessible.name: text
        }
    }

    // ---- Next slide button (bottom-right) ---------------------------------
    Rectangle {
        id: btn; width: 120; height: 42; radius: 8
        anchors { bottom: parent.bottom; right: parent.right; margins: 20 }
        color: btnArea.containsMouse ? presentation.cCyan : presentation.cBlue
        activeFocusOnTab: true
        border.color: Qt.lighter(presentation.cCyan, 1.2)
        border.width: activeFocus ? 2 : 0

        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on scale { NumberAnimation { duration: 150 } }
        scale: btnArea.containsMouse ? 1.05 : 1.0

        Text {
            anchors.centerIn: parent
            text: qsTr("Next Slide →"); color: "white"
            font.pixelSize: 13; font.bold: true
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: presentation.advance()
            onEntered: presentation.pauseLocks++
            onExited: presentation.pauseLocks--
        }
        Accessible.role: Accessible.Button; Accessible.name: qsTr("Next Slide")
        Keys.onReturnPressed: presentation.advance()
        Keys.onSpacePressed: presentation.advance()
    }

    // ---- Keyboard navigation ----------------------------------------------
    Keys.onRightPressed: presentation.advance()
    Keys.onLeftPressed: presentation.advance()
    Keys.onSpacePressed: presentation.advance()
}
