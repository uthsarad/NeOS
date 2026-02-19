import QtQuick 2.0;
import Calamares 1.0;

Presentation {
    id: presentation
    property bool paused: false
    focus: true

    Keys.onRightPressed: presentation.advance()
    Keys.onSpacePressed: presentation.advance()

    Timer {
        interval: 5000
        running: !presentation.paused
        repeat: true
        onTriggered: presentation.advance()
    }

    Slide {
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: presentation.paused = true
            onExited: presentation.paused = false
            onClicked: {
                presentation.forceActiveFocus()
                presentation.advance()
            }
            z: 1
        }

        Rectangle {
            id: slide1Background
            anchors.centerIn: parent
            width: parent.width * 0.9
            height: slide1Content.height + 60
            color: "#99000000"
            radius: 10
            border.width: presentation.activeFocus ? 2 : 0
            border.color: "#ffffff"

            Text {
                text: qsTr("Paused")
                color: "white"
                opacity: 0.7
                font.pixelSize: 14
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 10
                visible: presentation.paused
                Accessible.role: Accessible.StaticText
                Accessible.name: text
            }

            NumberAnimation on opacity {
                from: 0
                to: 1
                duration: 800
                running: slide1Background.visible
            }

            Column {
                id: slide1Content
                anchors.centerIn: parent
                width: parent.width - 40
                spacing: 20

                Image {
                    source: "welcome.png"
                    width: 200
                    height: 200
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                    // Accessibility
                    Accessible.role: Accessible.Graphic
                    Accessible.name: qsTr("Welcome to NeOS Logo")
                }

                Text {
                    text: qsTr("Welcome to NeOS")
                    color: "white"
                    font.pixelSize: 32
                    font.bold: true
                    width: parent.width
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    textFormat: Text.PlainText
                    // Accessibility
                    Accessible.role: Accessible.StaticText
                    Accessible.name: text
                }

                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: "white"
                        opacity: 1.0
                        Accessible.role: Accessible.Graphic
                        Accessible.name: qsTr("Slide 1 active")
                    }

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: "white"
                        opacity: 0.5
                        Accessible.role: Accessible.Graphic
                        Accessible.name: qsTr("Slide 2 inactive")
                    }
                }
            }
        }
    }

    Slide {
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: presentation.paused = true
            onExited: presentation.paused = false
            onClicked: {
                presentation.forceActiveFocus()
                presentation.advance()
            }
            z: 1
        }

        Rectangle {
            id: slide2Background
            anchors.centerIn: parent
            width: parent.width * 0.9
            height: slide2Content.height + 60
            color: "#99000000"
            radius: 10
            border.width: presentation.activeFocus ? 2 : 0
            border.color: "#ffffff"

            Text {
                text: qsTr("Paused")
                color: "white"
                opacity: 0.7
                font.pixelSize: 14
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 10
                visible: presentation.paused
                Accessible.role: Accessible.StaticText
                Accessible.name: text
            }

            NumberAnimation on opacity {
                from: 0
                to: 1
                duration: 800
                running: slide2Background.visible
            }

            Column {
                id: slide2Content
                anchors.centerIn: parent
                width: parent.width - 40
                spacing: 20

                Image {
                    source: "logo.png"
                    width: 150
                    height: 150
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                    // Accessibility
                    Accessible.role: Accessible.Graphic
                    Accessible.name: qsTr("NeOS Logo")
                }

                Text {
                    text: qsTr("Fast, Secure, Reliable")
                    color: "white"
                    font.pixelSize: 24
                    font.bold: true
                    width: parent.width
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    textFormat: Text.PlainText
                    // Accessibility
                    Accessible.role: Accessible.StaticText
                    Accessible.name: text
                }

                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: "white"
                        opacity: 0.5
                        Accessible.role: Accessible.Graphic
                        Accessible.name: qsTr("Slide 1 inactive")
                    }

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: "white"
                        opacity: 1.0
                        Accessible.role: Accessible.Graphic
                        Accessible.name: qsTr("Slide 2 active")
                    }
                }
            }
        }
    }
}
