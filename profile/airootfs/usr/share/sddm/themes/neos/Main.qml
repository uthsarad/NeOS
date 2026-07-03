// NeOS SDDM login theme — Ubuntu-inspired polished design.
// Nations Trust Bank (NTB) palette on deep navy.
// Pure QtQuick (no QtQuick.Controls, no shaders/blur) for VM compatibility
// with software rendering.
import QtQuick 2.15

Rectangle {
    id: root
    width: 1920; height: 1080
    color: "#0b0e1a"

    // ---- NTB palette -------------------------------------------------------
    readonly property color cBlue:    "#0088CF"
    readonly property color cCyan:    "#0096D5"
    readonly property color cMagenta: "#EB008B"
    readonly property color cText:    "#e6e9f2"
    readonly property color cMuted:   "#9aa0b6"
    readonly property color cDimmed:  "#6b7080"
    readonly property color cField:   "#0f1428"
    readonly property color cBorder:  "#2a3354"
    readonly property color cCard:    "#0e1326"
    readonly property color cError:   "#ff6b74"
    readonly property color cBgTop:   "#0a0e1a"
    readonly property color cBgBot:   "#16203a"

    // ---- Session list (extracted from sessionModel via a hidden Repeater) --
    property var sessionNames: []
    property int sessionIndex: sessionModel.lastIndex
    Repeater {
        model: sessionModel
        Item { Component.onCompleted: root.sessionNames[index] = model.name }
    }

    // ---- Background: gradient with optional wallpaper overlay --------------
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.cBgTop }
            GradientStop { position: 1.0; color: root.cBgBot }
        }
    }
    Image {
        anchors.fill: parent
        source: config.background ? config.background : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: status === Image.Ready
    }
    // Darkening scrim for readability over any wallpaper
    Rectangle {
        anchors.fill: parent; color: "#0b0e1a"; opacity: 0.50
    }

    // ---- Layout ------------------------------------------------------------
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top; anchors.topMargin: 70
        spacing: 4
        Text {
            id: titleText
            anchors.horizontalCenter: parent.horizontalCenter
            text: "NeOS"; color: root.cText
            font.pixelSize: 28; font.bold: true
            font.letterSpacing: 2
        }
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 40; height: 2; radius: 1
            color: root.cBlue; opacity: 0.6
        }
    }

    // ---- Clock (centred above the login card) ------------------------------
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top; anchors.topMargin: 140
        spacing: 4
        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cText; font.pixelSize: 56; font.weight: Font.Light
            text: Qt.formatDateTime(new Date(), "HH:mm")
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cMuted; font.pixelSize: 16; font.weight: Font.Light
            text: Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy")
        }
    }
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: clock.text = Qt.formatDateTime(new Date(), "HH:mm")
    }

    // ---- Login card (vertically centred, positioned below the clock) -----
    Rectangle {
        id: card
        width: 400
        height: contentCol.height + 56
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: 40
        }
        radius: 16
        color: root.cCard
        border.color: root.cBorder; border.width: 1

        // Subtle glow at the top of the card
        Rectangle {
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
            width: 120; height: 2; radius: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: root.cCyan }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Column {
            id: contentCol
            width: parent.width - 56
            anchors.centerIn: parent
            spacing: 16

            // Avatar circle
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 56; height: 56; radius: 28
                color: Qt.rgba(0, 0.53, 0.81, 0.15)
                border.color: root.cBorder; border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "👤"; font.pixelSize: 24
                }
            }

            // Username field
            Rectangle {
                width: parent.width; height: 48; radius: 10
                color: root.cField
                border.color: userInput.activeFocus ? root.cCyan : root.cBorder
                border.width: userInput.activeFocus ? 2 : 1
                TextInput {
                    id: userInput
                    anchors.fill: parent
                    anchors.leftMargin: 16; anchors.rightMargin: 16
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.cText; font.pixelSize: 15; font.weight: Font.Normal
                    clip: true
                    text: userModel.lastUser
                    cursorVisible: userInput.activeFocus
                    onAccepted: passInput.forceActiveFocus()
                    KeyNavigation.tab: passInput
                }
                Text {
                    anchors.fill: parent; anchors.leftMargin: 16
                    verticalAlignment: Text.AlignVCenter
                    text: "Username"; color: root.cDimmed; font.pixelSize: 15
                    visible: userInput.text.length === 0 && !userInput.activeFocus
                }
            }

            // Password field
            Rectangle {
                width: parent.width; height: 48; radius: 10
                color: root.cField
                border.color: passInput.activeFocus ? root.cCyan : root.cBorder
                border.width: passInput.activeFocus ? 2 : 1
                TextInput {
                    id: passInput
                    anchors.fill: parent
                    anchors.leftMargin: 16; anchors.rightMargin: 16
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.cText; font.pixelSize: 15
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    clip: true
                    cursorVisible: passInput.activeFocus
                    onAccepted: root.doLogin()
                }
                Text {
                    anchors.fill: parent; anchors.leftMargin: 16
                    verticalAlignment: Text.AlignVCenter
                    text: "Password"; color: root.cDimmed; font.pixelSize: 15
                    visible: passInput.text.length === 0 && !passInput.activeFocus
                }
            }

            // Login button (NTB blue, full-width)
            Rectangle {
                id: loginBtn
                width: parent.width; height: 48; radius: 10
                color: loginArea.pressed ? "#006fa8"
                       : (loginArea.containsMouse ? root.cCyan : root.cBlue)
                Behavior on color { ColorAnimation { duration: 150 } }
                Text {
                    anchors.centerIn: parent
                    text: "Log In"; color: "white"
                    font.pixelSize: 16; font.bold: true
                }
                MouseArea {
                    id: loginArea
                    anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.doLogin()
                }
            }

            // Status message (login failed, etc.)
            Text {
                id: message
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: root.cError; font.pixelSize: 13
                text: ""
            }

            // Session selector + power actions
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                Text {
                    color: root.cMuted; font.pixelSize: 12
                    text: "Session: " + (root.sessionNames[root.sessionIndex] || "Default")
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (sessionModel.count > 0)
                                root.sessionIndex = (root.sessionIndex + 1) % sessionModel.count;
                        }
                    }
                }
                Text {
                    visible: sddm.canSuspend
                    color: root.cMuted; font.pixelSize: 12; text: "Sleep"
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sddm.suspend() }
                }
                Text {
                    visible: sddm.canReboot
                    color: root.cMuted; font.pixelSize: 12; text: "Restart"
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sddm.reboot() }
                }
                Text {
                    visible: sddm.canPowerOff
                    color: root.cMuted; font.pixelSize: 12; text: "Shut Down"
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sddm.powerOff() }
                }
            }
        }
    }

    // ---- Login plumbing ----------------------------------------------------
    function doLogin() {
        message.text = "";
        sddm.login(userInput.text, passInput.text, root.sessionIndex);
    }

    Connections {
        target: sddm
        function onLoginSucceeded() { message.text = ""; }
        function onLoginFailed() {
            message.text = "Login failed — check your password.";
            passInput.text = "";
            passInput.forceActiveFocus();
        }
    }

    Component.onCompleted: {
        if (userInput.text.length > 0) passInput.forceActiveFocus();
        else userInput.forceActiveFocus();
    }
}
