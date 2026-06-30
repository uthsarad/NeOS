// NeOS SDDM login theme — Nations Trust Bank (NTB) palette on deep navy.
// Deliberately plain QtQuick (no QtQuick.Controls, no shaders/blur) so it
// renders correctly under software rendering in VMs without a GPU.
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
    readonly property color cField:   "#0f1428"
    readonly property color cBorder:  "#2a3354"

    // ---- Session list (extracted from sessionModel via a hidden Repeater) --
    property var sessionNames: []
    property int sessionIndex: sessionModel.lastIndex
    Repeater {
        model: sessionModel
        Item { Component.onCompleted: root.sessionNames[index] = model.name }
    }

    // ---- Background: wallpaper with navy gradient fallback ------------------
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0a0e1a" }
            GradientStop { position: 1.0; color: "#16203a" }
        }
    }
    Image {
        anchors.fill: parent
        source: config.background ? config.background : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: status === Image.Ready
    }
    // Darkening scrim so the login card stays readable over any wallpaper
    Rectangle { anchors.fill: parent; color: "#0b0e1a"; opacity: 0.55 }

    // ---- Clock -------------------------------------------------------------
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 90
        spacing: 4
        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cText; font.pixelSize: 64; font.bold: true
            text: Qt.formatDateTime(new Date(), "HH:mm")
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cMuted; font.pixelSize: 18
            text: Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy")
        }
    }
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: clock.text = Qt.formatDateTime(new Date(), "HH:mm")
    }

    // ---- Login card --------------------------------------------------------
    Rectangle {
        id: card
        width: 380
        height: contentCol.height + 56
        anchors.centerIn: parent
        radius: 14
        color: "#0e1326"
        border.color: root.cBorder
        border.width: 1

        Column {
            id: contentCol
            width: parent.width - 56
            anchors.centerIn: parent
            spacing: 18

            // NeOS wordmark
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "NeOS"; color: root.cText
                font.pixelSize: 34; font.bold: true
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 70; height: 4; radius: 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: root.cBlue }
                    GradientStop { position: 1.0; color: root.cMagenta }
                }
            }

            // Username field
            Rectangle {
                width: parent.width; height: 44; radius: 8
                color: root.cField
                border.color: userInput.activeFocus ? root.cCyan : root.cBorder
                border.width: userInput.activeFocus ? 2 : 1
                TextInput {
                    id: userInput
                    anchors.fill: parent
                    anchors.leftMargin: 14; anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.cText; font.pixelSize: 16
                    clip: true
                    text: userModel.lastUser
                    onAccepted: passInput.forceActiveFocus()
                    KeyNavigation.tab: passInput
                }
                Text {
                    anchors.fill: parent; anchors.leftMargin: 14
                    verticalAlignment: Text.AlignVCenter
                    text: "Username"; color: root.cMuted; font.pixelSize: 16
                    visible: userInput.text.length === 0 && !userInput.activeFocus
                }
            }

            // Password field
            Rectangle {
                width: parent.width; height: 44; radius: 8
                color: root.cField
                border.color: passInput.activeFocus ? root.cCyan : root.cBorder
                border.width: passInput.activeFocus ? 2 : 1
                TextInput {
                    id: passInput
                    anchors.fill: parent
                    anchors.leftMargin: 14; anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.cText; font.pixelSize: 16
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    clip: true
                    onAccepted: root.doLogin()
                }
                Text {
                    anchors.fill: parent; anchors.leftMargin: 14
                    verticalAlignment: Text.AlignVCenter
                    text: "Password"; color: root.cMuted; font.pixelSize: 16
                    visible: passInput.text.length === 0 && !passInput.activeFocus
                }
            }

            // Login button (NTB blue)
            Rectangle {
                id: loginBtn
                width: parent.width; height: 46; radius: 8
                color: loginArea.pressed ? "#006fa8"
                       : (loginArea.containsMouse ? root.cCyan : root.cBlue)
                Text {
                    anchors.centerIn: parent
                    text: "Log In"; color: "white"
                    font.pixelSize: 17; font.bold: true
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
                color: "#ff6b74"; font.pixelSize: 13
                text: ""
            }

            // Session selector (click to cycle) + power actions
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 18
                Text {
                    color: root.cMuted; font.pixelSize: 13
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
                    color: root.cMuted; font.pixelSize: 13; text: "Sleep"
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sddm.suspend() }
                }
                Text {
                    visible: sddm.canReboot
                    color: root.cMuted; font.pixelSize: 13; text: "Restart"
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sddm.reboot() }
                }
                Text {
                    visible: sddm.canPowerOff
                    color: root.cMuted; font.pixelSize: 13; text: "Shut Down"
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
